require 'rails_helper'

RSpec.describe CCMS::Submitters::UploadDocumentsService do
  let(:legal_aid_application) do
    create :legal_aid_application,
           :with_applicant,
           :with_proceeding_types,
           :with_opponent,
           :with_transaction_period,
           :with_means_report,
           :with_merits_report,
           :with_bank_transaction_report,
           :submitting_assessment
  end

  let!(:chances_of_success) { create :chances_of_success, application_proceeding_type: legal_aid_application.lead_application_proceeding_type }
  let(:statement_of_case) { create :statement_of_case, :with_original_and_pdf_files_attached, legal_aid_application: legal_aid_application }
  let(:statement_of_case_attachment) { statement_of_case.original_attachments.first }
  let(:means_report_attachment) { legal_aid_application.means_report }
  let(:merits_report_attachment) { legal_aid_application.merits_report }
  let(:bank_transaction_report_attachment) { legal_aid_application.bank_transaction_report }
  let!(:statement_of_case_submission_document) { create :submission_document, :id_obtained, submission: submission, attachment_id: statement_of_case_attachment.id }
  let!(:means_report_document) { create :submission_document, :id_obtained, submission: submission, document_type: :means_report, attachment_id: means_report_attachment.id }
  let!(:merits_report_document) { create :submission_document, :id_obtained, submission: submission, document_type: :merits_report, attachment_id: merits_report_attachment.id }
  let!(:bank_transaction_report_document) do
    create :submission_document, :id_obtained, submission: submission, document_type: :bank_transaction_report, attachment_id: bank_transaction_report_attachment.id
  end
  let(:expected_response) { ccms_data_from_file 'case_add_status_response.xml' }

  let(:submission) do
    create :submission,
           :case_created,
           legal_aid_application: legal_aid_application,
           case_ccms_reference: Faker::Number.number(digits: 9)
  end

  let(:histories) { CCMS::SubmissionHistory.order(:created_at).where(submission_id: submission.id) }
  let(:first_history) { histories.first }
  let(:document_upload_requestor) do
    double CCMS::Requestors::DocumentUploadRequestor.new(submission.case_ccms_reference,
                                                         statement_of_case_attachment.id,
                                                         'base64encodedpdf',
                                                         'my_login',
                                                         nil)
  end
  let(:document_upload_response) { ccms_data_from_file 'document_upload_response.xml' }
  let(:transaction_request_id_in_example_response) { '20190301030405123456' }
  subject { described_class.new(submission) }

  before do
    allow(CCMS::Requestors::DocumentUploadRequestor).to receive(:new).and_return(document_upload_requestor)
    allow(document_upload_requestor).to receive(:transaction_request_id).and_return(transaction_request_id_in_example_response)
    allow(document_upload_requestor).to receive(:formatted_xml).and_return(expected_response)
  end

  context 'operation successful' do
    let(:history) { histories.where(to_state: 'completed').last }

    before do
      allow(document_upload_requestor).to receive(:call).and_return(document_upload_response)
    end

    it 'creates a DocumentUploadRequestor object for each document to be uploaded' do
      expect(CCMS::Requestors::DocumentUploadRequestor).to receive(:new).exactly(submission.submission_documents.count).times
      subject.call
    end

    it 'encodes each document as base64' do
      expect(Base64).to receive(:strict_encode64).exactly(submission.submission_documents.count).times
      subject.call
    end

    it 'updates the status for each document to uploaded' do
      subject.call
      submission.submission_documents.each do |document|
        expect(document.status).to eq 'uploaded'
      end
    end

    it 'changes the submission state to completed' do
      expect { subject.call }.to change { submission.aasm_state }.to 'completed'
    end

    it 'writes a history record for each document and on completion' do
      expect { subject.call }.to change { CCMS::SubmissionHistory.count }.by(5)
    end

    it 'writes a history record on completion that updates the state' do
      subject.call
      expect(history.from_state).to eq 'case_created'
      expect(history.to_state).to eq 'completed'
      expect(history.success).to be true
      expect(history.details).to be_nil
    end
  end

  context 'operation unsuccessful' do
    let(:history) { histories.where(request: nil, response: nil, to_state: 'failed').last }

    context 'operation fails due to a CCMS::CCMSError exception' do
      let(:error) { [CCMS::CCMSError, Savon::Error, StandardError] }

      before do
        fake_error = error.sample
        allow(document_upload_requestor).to receive(:call).and_raise(fake_error, 'this document submission has failed')
        expect { subject.call }.to raise_error(CCMS::CCMSError, /The following documents failed to upload:/)
      end

      it 'does not change the submission state' do
        expect(submission.reload.aasm_state).to eq 'case_created'
      end

      it 'writes a history record for each document and on completion' do
        submission_history = submission.submission_history
        expect(submission_history.count).to eq 5
      end

      it 'writes a history record on completion that updates the state' do
        expect(first_history.from_state).to eq 'case_created'
        expect(first_history.to_state).to eq 'failed'
        expect(first_history.success).to be false
        expect(first_history.details).to match(/#{error}/)
        expect(first_history.details).to match(/this document submission has failed/)
      end

      it 'writes a history record on completion that updates the state' do
        expect(history.from_state).to eq 'case_created'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/#{error}/)
        expect(history.details).to match(/failed to upload/)
      end
    end

    context 'operation fails due to an error response from ccms' do
      before do
        allow_any_instance_of(CCMS::Parsers::DocumentUploadResponseParser).to receive(:success?).and_return(false)
        allow(document_upload_requestor).to receive(:call).and_return(document_upload_response)
        expect { subject.call }.to raise_error(CCMS::CCMSError)
      end

      it 'writes a history record for each document and on completion' do
        submission_history = submission.submission_history
        expect(submission_history.count).to eq 5
      end

      it 'writes a history record on completion that updates the state' do
        expect(history.from_state).to eq 'case_created'
        expect(history.to_state).to eq 'failed'
        expect(history.success).to be false
        expect(history.details).to match(/CCMS::CCMSError/)
        expect(history.details).to match(/The following documents failed to upload/)
      end
    end
  end
end
