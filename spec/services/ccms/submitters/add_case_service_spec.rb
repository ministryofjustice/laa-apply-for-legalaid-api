require 'rails_helper'

module CCMS
  module Submitters # rubocop:disable Metrics/ModuleLength
    RSpec.describe AddCaseService do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_proceeding_types,
               :with_chances_of_success,
               :with_everything_and_address,
               :with_cfe_v3_result,
               :with_positive_benefit_check_result,
               office_id: office.id,
               populate_vehicle: true
      end
      let(:applicant) { legal_aid_application.applicant }
      let(:office) { create :office }
      let(:submission) { create :submission, :applicant_ref_obtained, legal_aid_application: legal_aid_application }
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
      let(:endpoint) { 'https://sitsoa10.laadev.co.uk/soa-infra/services/default/CaseServices/CaseServices_ep' }
      let(:response_body) { ccms_data_from_file 'case_add_response.xml' }

      subject { described_class.new(submission) }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      before do
        # stub a post request - any body, any headers
        stub_request(:post, endpoint).to_return(body: response_body, status: 200)

        # stub the transaction request id that we expect in the response
        allow_any_instance_of(CCMS::Requestors::CaseAddRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
      end

      context 'operation successful' do
        it 'sets state to case_submitted' do
          subject.call
          expect(submission.aasm_state).to eq 'case_submitted'
        end

        it 'records the transaction id of the request' do
          subject.call
          expect(submission.case_add_transaction_id).to eq '20190301030405123456'
        end

        context 'there are documents to upload' do
          let(:submission) { create :submission, :document_ids_obtained, legal_aid_application: legal_aid_application }
          it 'writes a history record' do
            expect { subject.call }.to change { SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'document_ids_obtained'
            expect(history.to_state).to eq 'case_submitted'
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it 'stores the reqeust body in the  submission history record' do
            subject.call
            expect(history.request).to be_soap_envelope_with(
              command: 'ns4:CaseAddRQ',
              transaction_id: '20190301030405123456',
              matching: [
                '<ns2:PreferredAddress>CLIENT</ns2:PreferredAddress>',
                "<ns2:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</ns2:ProviderOfficeID>"
              ]
            )
          end

          it 'stores the response body in the submission history record' do
            subject.call
            expect(history.response).to eq response_body
          end
        end

        context 'there are no documents to upload' do
          it 'writes a history record' do
            expect { subject.call }.to change { SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'applicant_ref_obtained'
            expect(history.to_state).to eq 'case_submitted'
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it 'stores the request body in the  submission history record' do
            subject.call
            expect(history.request).to be_soap_envelope_with(
              command: 'ns4:CaseAddRQ',
              transaction_id: '20190301030405123456',
              matching: [
                "<ns2:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</ns2:ProviderOfficeID>"
              ]
            )
          end

          it 'writes the response body to the history record' do
            subject.call
            expect(history.response).to eq response_body
          end
        end
      end

      context 'operation in error' do
        context 'error when adding a case' do
          let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

          before do
            fake_error = error.sample
            expect_any_instance_of(CCMS::Requestors::CaseAddRequestor).to receive(:call).and_raise(fake_error, 'oops')
            expect { subject.call }.to raise_error(fake_error, 'oops')
          end

          it 'does not change the state' do
            expect(submission.aasm_state).to eq 'applicant_ref_obtained'
          end

          it 'records the error in the submission history' do
            expect(SubmissionHistory.count).to eq 1
            expect(history.from_state).to eq 'applicant_ref_obtained'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to match(/#{error}/)
            expect(history.details).to match(/oops/)
            expect(history.request).to be_soap_envelope_with(
              command: 'ns4:CaseAddRQ',
              transaction_id: '20190301030405123456',
              matching: [
                '<ns2:PreferredAddress>CLIENT</ns2:PreferredAddress>',
                "<ns2:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</ns2:ProviderOfficeID>"
              ]
            )
          end
        end

        context 'unsuccessful response from CCMS adding a case' do
          let(:response_body) { ccms_data_from_file 'case_add_response_failure.xml' }

          before do
            expect { subject.call }.to raise_error(CCMS::CCMSUnsuccessfulResponseError, "AddCaseService failed with unsuccessful response for submission: #{submission.id}")
          end

          it 'does not change state' do
            expect(submission.aasm_state).to eq 'applicant_ref_obtained'
          end

          it 'records the error in the submission history' do
            expect(SubmissionHistory.count).to eq 1
            expect(history.from_state).to eq 'applicant_ref_obtained'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
          end

          it 'stores the reqeust body in the  submission history record' do
            expect(history.request).to be_soap_envelope_with(
              command: 'ns4:CaseAddRQ',
              transaction_id: '20190301030405123456',
              matching: [
                "<ns2:ProviderOfficeID>#{legal_aid_application.office.ccms_id}</ns2:ProviderOfficeID>"
              ]
            )
          end

          it 'stores the response body in the submission history record' do
            expect(history.response).to eq response_body
          end
        end
      end
    end
  end
end
