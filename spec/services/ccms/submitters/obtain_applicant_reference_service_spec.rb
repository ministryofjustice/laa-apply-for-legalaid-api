require 'rails_helper'

module CCMS
  module Submitters # rubocop:disable Metrics/ModuleLength
    RSpec.describe ObtainApplicantReferenceService do
      let(:legal_aid_application) { create :legal_aid_application, :with_proceeding_types, :with_everything_and_address, populate_vehicle: true }
      let(:applicant) { legal_aid_application.applicant }
      let(:submission) { create :submission, :case_ref_obtained, legal_aid_application: legal_aid_application }
      let(:histories) { CCMS::SubmissionHistory.where(submission_id: submission.id).order(:created_at) }
      let(:latest_history) { histories.reload.last }
      let(:request_body) { ccms_data_from_file 'applicant_search_request.xml' }
      let(:response_body) { ccms_data_from_file 'applicant_search_response_one_result.xml' }
      let(:empty_response_body) { ccms_data_from_file 'applicant_search_response_no_results.xml' }
      let(:no_applicant_details_response_body) { ccms_data_from_file 'applicant_search_response_results_no_details.xml' }
      let(:endpoint) { 'https://sitsoa10.laadev.co.uk/soa-infra/services/default/ClientServices/ClientServices_ep' }
      let(:success_add_applicant_response_body) { ccms_data_from_file 'applicant_add_response_success.xml' }

      subject { described_class.new(submission) }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      before do
        # stub the transaction request id that we expect in the response
        allow_any_instance_of(CCMS::Requestors::ApplicantSearchRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
      end

      context 'operation successful' do
        context 'applicant exists on the CCMS system' do
          before do
            stub_request(:post, endpoint).with(body: /ClientInqRQ/).to_return(body: response_body, status: 200)
          end
          let(:applicant_ccms_reference_in_example_response) { '4390016' }

          it 'updates the applicant_ccms_reference' do
            subject.call
            expect(submission.applicant_ccms_reference).to eq applicant_ccms_reference_in_example_response
          end

          it 'sets the state to applicant_ref_obtained' do
            subject.call
            expect(submission.aasm_state).to eq 'applicant_ref_obtained'
          end

          it 'writes a history record' do
            expect { subject.call }.to change { SubmissionHistory.count }.by(1)
            expect(latest_history.from_state).to eq 'case_ref_obtained'
            expect(latest_history.to_state).to eq 'applicant_ref_obtained'
            expect(latest_history.success).to be true
            expect(latest_history.details).to be_nil
          end

          it 'stores the reqeust body in the submission history record' do
            subject.call
            expect(latest_history.request).to be_soap_envelope_with(
              command: 'ns2:ClientInqRQ',
              transaction_id: '20190301030405123456',
              matching: [
                "<ns5:Surname>#{applicant.last_name}</ns5:Surname>",
                "<ns5:FirstName>#{applicant.first_name}</ns5:FirstName>"
              ]
            )
          end

          it 'stores the response body in the submission history record' do
            subject.call
            expect(latest_history.response).to eq response_body
          end
        end

        shared_examples 'applicant does not exist on CCMS' do
          before do
            # stub a post request
            stub_request(:post, endpoint).with(body: /ClientInqRQ/).to_return(body: empty_response_body, status: 200)
            stub_request(:post, endpoint).with(body: /ClientAddRQ/).to_return(body: success_add_applicant_response_body, status: 200)
            expect_any_instance_of(CCMS::Requestors::ApplicantAddRequestor).to receive(:transaction_request_id).at_least(1).and_return('20190301030405123456')
          end

          it 'sets the state to applicant_submitted' do
            subject.call
            expect(submission.aasm_state).to eq 'applicant_submitted'
          end

          it 'writes a history record' do
            expect { subject.call }.to change { SubmissionHistory.count }.by(2)
            expect(latest_history.from_state).to eq 'case_ref_obtained'
            expect(latest_history.to_state).to eq 'applicant_submitted'
            expect(latest_history.success).to be true
            expect(latest_history.details).to be_nil
          end

          it 'stores the request body in the submission history record' do
            subject.call
            expect(latest_history.request).to be_soap_envelope_with(
              command: 'ns2:ClientAddRQ',
              transaction_id: '20190301030405123456',
              matching: [
                "<ns4:Surname>#{applicant.last_name}</ns4:Surname>",
                "<ns4:FirstName>#{applicant.first_name}</ns4:FirstName>"
              ]
            )
          end

          it 'stores the response body in the submission history record' do
            subject.call
            expect(latest_history.response).to eq success_add_applicant_response_body
          end

          it 'calls the AddApplicant service' do
            expect(CCMS::Submitters::AddApplicantService).to receive(:new).and_call_original
            subject.call
          end
        end

        context 'applicant exists on CCMS but applicant details are not returned' do
          before { stub_request(:post, endpoint).with(body: /ClientInqRQ/).to_return(body: no_applicant_details_response_body, status: 200) }
          it_behaves_like 'applicant does not exist on CCMS'
        end
      end

      context 'operation in error' do
        context 'error when searching for applicant' do
          let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

          before do
            fake_error = error.sample
            expect_any_instance_of(CCMS::Requestors::ApplicantSearchRequestor).to receive(:call).and_raise(fake_error, 'oops')
            expect { subject.call }.to raise_error(fake_error, 'oops')
          end

          it 'does not change the state' do
            expect(submission.aasm_state).to eq 'case_ref_obtained'
          end

          it 'records the error in the submission history' do
            expect(SubmissionHistory.count).to eq 1
            expect(latest_history.from_state).to eq 'case_ref_obtained'
            expect(latest_history.to_state).to eq 'failed'
            expect(latest_history.success).to be false
            expect(latest_history.details).to match(/#{error}/)
            expect(latest_history.details).to match(/oops/)
            expect(latest_history.request).to be_soap_envelope_with(
              command: 'ns2:ClientInqRQ',
              transaction_id: '20190301030405123456',
              matching: [
                "<ns5:Surname>#{applicant.last_name}</ns5:Surname>",
                "<ns5:FirstName>#{applicant.first_name}</ns5:FirstName>"
              ]
            )
          end
        end
      end
    end
  end
end
