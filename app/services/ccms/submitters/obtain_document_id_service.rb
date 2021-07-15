module CCMS
  module Submitters
    class ObtainDocumentIdService < BaseSubmissionService
      NON_PDF_VERSION_ATTACHMENTS = %w[statement_of_case gateway_evidence].freeze

      def call
        return unless populate_documents

        submission.submission_documents.each do |document|
          request_document_id(document)
        end
        raise CCMSError, "Failed to obtain document ids for: #{failed_requesting_ids}" if failed_requesting_ids.present?

        submission.obtain_document_ids!
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, nil)
        raise
      end

      private

      def pdf_attachments
        # Ignore the original document and use the pdf attachment it was converted to

        @pdf_attachments ||= attachments.reject { |a| NON_PDF_VERSION_ATTACHMENTS.include? a.attachment_type }
      end

      def attachments
        legal_aid_application.attachments.all
      end

      def legal_aid_application
        @legal_aid_application ||= submission.legal_aid_application
      end

      def populate_documents
        pdf_attachments.each do |attachment|
          SubmissionDocument.create!(
            submission: submission,
            attachment_id: attachment.id,
            status: :new,
            document_type: attachment.attachment_type,
            ccms_document_id: nil
          )
        end
      end

      def request_document_id(document)
        document_id_requestor = document_id_requestor(document.document_type)
        response = update_document_and_return_response(document, document_id_requestor)
        document.save!
        create_history('applicant_ref_obtained', 'document_ids_obtained', document_id_requestor.formatted_xml, response) if submission.save!
      rescue *CCMS_SUBMISSION_ERRORS => e
        document.status = :failed
        document.save!
        handle_exception(e, document_id_requestor.formatted_xml)
        raise
      end

      def ccms_document_id(dir)
        Parsers::DocumentIdResponseParser.new(dir.transaction_request_id, dir.call).document_id
      end

      def document_id_requestor(document_type)
        Requestors::DocumentIdRequestor.new(submission.case_ccms_reference, submission.legal_aid_application.provider.username, document_type)
      end

      def update_document_and_return_response(document, document_id_requestor)
        document.ccms_document_id = ccms_document_id(document_id_requestor)
        document.status = :id_obtained
        document_id_requestor.call
      end

      def failed_requesting_ids
        @failed_requesting_ids ||= submission.submission_documents.select { |document| document.status == 'failed' }&.map(&:id)&.join(', ')
      end
    end
  end
end
