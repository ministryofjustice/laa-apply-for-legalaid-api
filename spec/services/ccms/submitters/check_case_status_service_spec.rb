require 'rails_helper'

RSpec.describe CCMS::Submitters::CheckCaseStatusService do
  let(:submission) { create :submission, :case_submitted }
  let(:case_add_status_requestor) { double CCMS::Requestors::CaseAddStatusRequestor }
  let(:history) { CCMS::SubmissionHistory.find_by(submission_id: submission.id) }
  let(:case_add_status_response) { ccms_data_from_file 'case_add_status_response.xml' }
  let(:case_add_status_request) { ccms_data_from_file 'case_add_status_request.xml' }
  subject { described_class.new(submission) }

  before do
    allow(subject).to receive(:case_add_status_requestor).and_return(case_add_status_requestor)
  end

  context 'applicant_submitted state' do
    context 'operation successful' do
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }

      context 'case not yet created' do
        before do
          allow(case_add_status_requestor).to receive(:formatted_xml).and_return(case_add_status_request)
          expect(case_add_status_requestor).to receive(:call).and_return(case_add_status_response)
          expect(case_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          allow_any_instance_of(CCMS::Parsers::CaseAddStatusResponseParser).to receive(:success?).and_return(false)
        end

        context 'poll count remains below limit' do
          it 'increments the poll count' do
            expect { subject.call }.to change { submission.case_poll_count }.by 1
          end

          it 'does not change the state' do
            expect { subject.call }.not_to change { submission.aasm_state }
          end

          it 'writes a history record' do
            expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'case_submitted'
            expect(history.to_state).to eq 'case_submitted'
            expect(history.success).to be true
            expect(history.details).to be_nil
          end

          it 'stores the reqeust body in the  submission history record' do
            subject.call
            expect(history.request).to be_soap_envelope_with(
              command: 'ns2:CaseAddUpdtStatusRQ',
              transaction_id: '20190101121530123456'
            )
          end

          it 'stores the response body in the submission history record' do
            subject.call
            expect(history.response).to eq case_add_status_response
          end
        end

        context 'poll count reaches limit' do
          before do
            submission.case_poll_count = CCMS::Submission::POLL_LIMIT - 1
          end

          it 'increments the poll count' do
            expect { subject.call }.to change { submission.case_poll_count }.by 1
          end

          it 'does not change the state' do
            expect { subject.call }.not_to change { submission.aasm_state }
          end

          it 'writes a history record' do
            expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
            expect(history.from_state).to eq 'case_submitted'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to eq 'Poll limit exceeded'
          end

          it 'stores the reqeust body in the  submission history record' do
            subject.call
            expect(history.request).to be_soap_envelope_with(
              command: 'ns2:CaseAddUpdtStatusRQ',
              transaction_id: '20190101121530123456'
            )
          end

          it 'does not store a response body in the submission history record' do
            subject.call
            expect(history.response).to be_nil
          end
        end
      end

      context 'case is created' do
        before do
          allow(case_add_status_requestor).to receive(:formatted_xml).and_return(case_add_status_request)
          expect(case_add_status_requestor).to receive(:call).and_return(case_add_status_response)
          expect(case_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
          allow_any_instance_of(CCMS::Parsers::CaseAddStatusResponseParser).to receive(:success?).and_return(true)
        end

        it 'changes the state to case_created' do
          expect { subject.call }.to change { submission.aasm_state }.to 'case_created'
        end

        it 'writes a history record' do
          expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(1)
          expect(history.from_state).to eq 'case_submitted'
          expect(history.to_state).to eq 'case_created'
          expect(history.request).to eq case_add_status_request
          expect(history.request).to_not be_nil
          expect(history.success).to be true
          expect(history.details).to be_nil
        end

        it 'stores the reqeust body in the  submission history record' do
          subject.call
          expect(history.request).to be_soap_envelope_with(
            command: 'ns2:CaseAddUpdtStatusRQ',
            transaction_id: '20190101121530123456'
          )
        end

        it 'stores the response body in the submission history record' do
          subject.call
          expect(history.response).to eq case_add_status_response
        end
      end
    end

    context 'operation unsuccessful' do
      let(:transaction_request_id_in_example_response) { '20190301030405123456' }
      let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

      before do
        fake_error = error.sample
        allow(case_add_status_requestor).to receive(:formatted_xml).and_return(case_add_status_request)
        expect(case_add_status_requestor).to receive(:call).and_raise(fake_error, 'oops')
        expect(case_add_status_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
        expect { subject.call }.to raise_error(fake_error, 'oops')
      end

      it 'increments the poll count' do
        expect(submission.case_poll_count).to eq 1
      end

      it 'does not change the state' do
        expect(submission.aasm_state).to eq 'case_submitted'
      end

      it 'records the error in the submission history' do
        expect(CCMS::SubmissionHistory.count).to eq 1
        expect(history.from_state).to eq 'case_submitted'
        expect(history.to_state).to eq 'failed'
        expect(history.request).to eq case_add_status_request
        expect(history.request).to_not be_nil
        expect(history.success).to be false
        expect(history.details).to match(/#{error}/)
        expect(history.details).to match(/oops/)
      end

      it 'stores the reqeust body in the  submission history record' do
        expect(history.request).to be_soap_envelope_with(
          command: 'ns2:CaseAddUpdtStatusRQ',
          transaction_id: '20190101121530123456'
        )
      end

      it 'does not store the response body in the submission history record' do
        expect(history.response).to be_nil
      end
    end
  end

  # private method tested here because it is mocked out above
  #
  describe '#case_add_status_requestor' do
    let(:service_double) { CCMS::Submitters::CheckCaseStatusService.new(submission) }
    let(:requestor1) { service_double.__send__(:case_add_status_requestor) }
    let(:requestor2) { service_double.__send__(:case_add_status_requestor) }
    it 'only instantiates one copy of the CaseAddStatusRequestor' do
      expect(requestor1).to be_instance_of(CCMS::Requestors::CaseAddStatusRequestor)
      expect(requestor1).to eq requestor2
    end
  end
end
