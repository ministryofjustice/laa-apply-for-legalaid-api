require 'rails_helper'

module CCMS
  module Submitters # rubocop:disable Metrics/ModuleLength
    RSpec.describe ObtainDocumentIdService do
      let(:legal_aid_application) do
        create :legal_aid_application,
               :with_applicant,
               :with_proceeding_types,
               :with_opponent,
               :with_transaction_period,
               :with_cfe_v3_result
      end
      let(:chances_of_success) { create :chances_of_success, application_proceeding_type: legal_aid_application.lead_application_proceeding_type }
      let(:submission) { create :submission, :applicant_ref_obtained, legal_aid_application: legal_aid_application, case_ccms_reference: Faker::Number.number }
      let!(:statement_of_case) { create :statement_of_case, legal_aid_application: legal_aid_application }
      let(:endpoint) { 'https://sitsoa10.laadev.co.uk/soa-infra/services/default/DocumentServices/DocumentServices_ep' }
      let(:history) { SubmissionHistory.where(submission_id: submission.id).last }
      let(:document_id_request) { ccms_data_from_file 'document_id_request.xml' }
      let(:response_body) { ccms_data_from_file 'document_id_response.xml' }

      subject { described_class.new(submission) }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      context 'operation successful' do
        before do
          # stub a post request - any body, any headers
          stub_request(:post, endpoint).to_return(body: response_body, status: 200)

          # stub the transaction request id that we expect in the response
          allow_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
        end

        context 'the application has no documents' do
          it 'does not create any document objects' do
            subject.call
            expect(submission.submission_documents.count).to eq 0
          end
        end

        context 'the application has documents to upload' do
          before do
            create :attachment, :merits_report, legal_aid_application: legal_aid_application
            create :attachment, :means_report, legal_aid_application: legal_aid_application
            create :attachment, :bank_transaction_report, legal_aid_application: legal_aid_application
            create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application
            create :gateway_evidence, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application
          end

          it 'populates the documents array with statement_of_case, gateway_evidence, means_report and merits_report' do
            subject.call
            expect(submission.submission_documents.count).to eq 5
          end

          it 'populates document array with gateway_evidence' do
            subject.call
            gateway_evidence_submission = submission.submission_documents.select { |a| a.document_type == 'gateway_evidence_pdf' }
            expect(gateway_evidence_submission.count).to eq 1
          end

          context 'when requesting document_ids' do
            it 'populates the ccms_document_id for each document' do
              subject.call
              submission.submission_documents.each do |document|
                expect(document.ccms_document_id).to_not be nil
              end
            end

            it 'updates the status for each document to id_obtained' do
              subject.call
              submission.submission_documents.each do |document|
                expect(document.status).to eq 'id_obtained'
              end
            end

            it 'changes the submission state to document_ids_obtained' do
              expect { subject.call }.to change { submission.aasm_state }.to 'document_ids_obtained'
            end

            it 'writes a history record for each document' do
              expect { subject.call }.to change { SubmissionHistory.count }.by(5)
            end

            it 'updates the history records' do
              subject.call
              expect(history.from_state).to eq 'applicant_ref_obtained'
              expect(history.to_state).to eq 'document_ids_obtained'
              expect(history.success).to be true
              expect(history.details).to be_nil
            end

            it 'writes the request body to the history record' do
              subject.call
              expect(history.request).to be_soap_envelope_with(
                command: 'ns2:DocumentUploadRQ',
                transaction_id: '20190301030405123456',
                matching: ['<ns4:Channel>E</ns4:Channel>']
              )
            end

            it 'creates three documents as ADMIN1, one as STATE and one as BSTMT' do
              subject.call
              admin1_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan(/ADMIN1/) }.flatten.count
              state_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan(/STATE/) }.flatten.count
              bstmt_documents = SubmissionHistory.where(submission_id: submission.id).map(&:request).map { |x| x.scan(/BSTMT/) }.flatten.count
              expect(admin1_documents).to eq 3
              expect(state_documents).to eq 1
              expect(bstmt_documents).to eq 1
            end

            it 'writes the response body to the history record' do
              subject.call
              expect(history.response).to eq response_body
            end
          end
        end
      end

      context 'operation unsuccessful' do
        let(:history) { SubmissionHistory.where(submission_id: submission.id, request: nil, response: nil).last }
        # There should only be one record in this state, so if it fails it's a legitimate error,
        # previously a race condition would occur where both records where created to
        # the microsecond :(
        context 'when populating documents' do
          let!(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application }
          let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

          before do
            fake_error = error.sample
            allow_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:transaction_request_id).and_return('20190301030405123456')
            expect_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:call).and_raise(fake_error, 'Failed to obtain document ids for')
            expect { subject.call }.to raise_error(fake_error, 'Failed to obtain document ids for')
          end

          it 'does not change the state' do
            expect(submission.aasm_state).to eq 'applicant_ref_obtained'
          end

          it 'writes a history record' do
            expect(SubmissionHistory.count).to eq 2
            expect(history.from_state).to eq 'applicant_ref_obtained' # this is failing gets case_submitted
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to match(/#{error}/)
            expect(history.details).to match(/Failed to obtain document ids for/)
            expect(history.request).to be_nil
            expect(history.response).to be_nil
          end
        end

        context 'when requesting document_ids' do
          before do
            expect_any_instance_of(CCMS::Requestors::DocumentIdRequestor).to receive(:call).and_raise(CCMSError, 'failure populating document hash')
            expect { subject.call }.to raise_error(CCMSError, 'failure populating document hash')
          end

          let(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application }

          it 'does not change the state' do
            expect(submission.aasm_state).to eq 'applicant_ref_obtained'
          end

          it 'changes the document state to failed' do
            expect(submission.submission_documents.first.status).to eq 'failed'
          end

          it 'writes a history record' do
            expect(SubmissionHistory.count).to eq 2
            expect(history.from_state).to eq 'applicant_ref_obtained'
            expect(history.to_state).to eq 'failed'
            expect(history.success).to be false
            expect(history.details).to match(/CCMS::CCMSError/)
            expect(history.details).to match(/failure populating document hash/)
            expect(history.request).to be_nil
            expect(history.response).to be_nil
          end
        end
      end
    end
  end
end
