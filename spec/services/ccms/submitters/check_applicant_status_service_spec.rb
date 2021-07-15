require 'rails_helper'

module CCMS
  module Submitters # rubocop:disable Metrics/ModuleLength
    RSpec.describe CheckApplicantStatusService do
      let(:submission) { create :submission, :applicant_submitted }
      let(:history) { SubmissionHistory.find_by(submission_id: submission.id) }
      let(:response_body) { ccms_data_from_file 'applicant_add_status_response.xml' }
      let(:endpoint) { 'https://sitsoa10.laadev.co.uk/soa-infra/services/default/ClientServices/ClientServices_ep' }

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
        allow_any_instance_of(CCMS::Requestors::ApplicantAddStatusRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
      end

      context 'applicant_submitted state' do
        context 'operation successful' do
          context 'applicant not yet created' do
            let(:response_body) { ccms_data_from_file 'applicant_add_status_response_no_such_party.xml' }
            context 'poll count remains below limit' do
              it 'increments the poll count' do
                expect { subject.call }.to change { submission.applicant_poll_count }.by 1
              end

              it 'does not change the state' do
                expect { subject.call }.not_to change { submission.aasm_state }
              end

              it 'writes a history record' do
                expect { subject.call }.to change { SubmissionHistory.count }.by(1)
                expect(history.from_state).to eq 'applicant_submitted'
                expect(history.to_state).to eq 'applicant_submitted'
                expect(history.success).to be true
                expect(history.details).to be_nil
                expect(history.request).not_to be_nil
              end

              it 'stores the reqeust body in the  submission history record' do
                subject.call
                expect(history.request).to be_soap_envelope_with(
                  command: 'ns2:ClientAddUpdtStatusRQ',
                  transaction_id: '20190301030405123456'
                )
              end

              it 'stores the response body in the submission history record' do
                subject.call
                expect(history.response).to eq response_body
              end
            end

            context 'poll count reaches limit' do
              before do
                submission.applicant_poll_count = Submission::POLL_LIMIT - 1
              end

              it 'increments the poll count' do
                expect { subject.call }.to change { submission.applicant_poll_count }.by 1
              end

              it 'does not change the state' do
                expect { subject.call }.not_to change { submission.aasm_state }
              end

              it 'writes a history record' do
                expect { subject.call }.to change { SubmissionHistory.count }.by(1)
                expect(history.from_state).to eq 'applicant_submitted'
                expect(history.to_state).to eq 'failed'
                expect(history.success).to be false
                expect(history.details).to match 'Poll limit exceeded'
              end

              it 'stores the reqeust body in the  submission history record' do
                subject.call
                expect(history.request).to be_soap_envelope_with(
                  command: 'ns2:ClientAddUpdtStatusRQ',
                  transaction_id: '20190301030405123456'
                )
              end
            end
          end

          context 'applicant is created' do
            let(:expected_applicant_ccms_reference) { Faker::Number.number.to_s }

            before do
              allow_any_instance_of(CCMS::Parsers::ApplicantAddStatusResponseParser).to receive(:applicant_ccms_reference).and_return(expected_applicant_ccms_reference)
            end

            it 'changes the state to applicant_ref_obtained' do
              expect { subject.call }.to change { submission.aasm_state }.to 'applicant_ref_obtained'
            end

            it 'updates the applicant_ccms_reference' do
              expect { subject.call }.to change { submission.applicant_ccms_reference }.to expected_applicant_ccms_reference
            end

            it 'writes a history record' do
              expect { subject.call }.to change { SubmissionHistory.count }.by(1)
              expect(history.from_state).to eq 'applicant_submitted'
              expect(history.to_state).to eq 'applicant_ref_obtained'
              expect(history.success).to be true
              expect(history.details).to be_nil
            end

            it 'stores the reqeust body in the  submission history record' do
              subject.call
              expect(history.request).to be_soap_envelope_with(
                command: 'ns2:ClientAddUpdtStatusRQ',
                transaction_id: '20190301030405123456'
              )
            end
          end
        end

        context 'operation unsuccessful' do
          let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

          before do
            fake_error = error.sample
            expect_any_instance_of(CCMS::Requestors::ApplicantAddStatusRequestor).to receive(:call).and_raise(fake_error, 'oops')
            expect { subject.call }.to raise_error(fake_error, 'oops')
          end

          it 'increments the poll count' do
            expect(submission.applicant_poll_count).to eq 1
          end

          it 'does not change state' do
            expect(submission.aasm_state).to eq 'applicant_submitted'
          end

          it 'records the error in the submission history' do
            expect(SubmissionHistory.count).to eq 1
            expect(history.from_state).to eq 'applicant_submitted'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to match(/#{error}/)
            expect(history.details).to match(/oops/)
            expect(history.request).to be_soap_envelope_with(
              command: 'ns2:ClientAddUpdtStatusRQ',
              transaction_id: '20190301030405123456'
            )
          end
        end
      end
    end
  end
end
