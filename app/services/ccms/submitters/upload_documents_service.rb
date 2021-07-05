module CCMS
  module Submitters
    class UploadDocumentsService < BaseSubmissionService
      def call
        submission.submission_documents.each do |submission_document|
          upload_document(submission_document)
        end

        raise CCMSError, "The following documents failed to upload: #{failed_upload_ids}" if failed_upload_ids.present?

        create_history('case_created', submission.aasm_state, nil, nil) if submission.complete!
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, nil)
        raise
      end

      private

      def failed_upload_ids
        @failed_upload_ids ||= submission.submission_documents.select { |document| document.status == 'failed' }&.map(&:id)&.join(', ')
      end

      def upload_document(submission_document)
        document_upload_requestor = document_upload_requestor(submission_document)
        response = update_document_status_and_return_response(submission_document, document_upload_requestor)
        submission_document.save!
        submission.save!
        create_history('case_created', submission_document.status, document_upload_requestor.formatted_xml, response)
      rescue *CCMS_SUBMISSION_ERRORS => e
        submission_document.status = :failed
        submission.save!
        create_ccms_failure_history('case_created', e, document_upload_requestor.formatted_xml)
      end

      def document_upload_requestor(submission_document)
        CCMS::Requestors::DocumentUploadRequestor.new(submission.case_ccms_reference,
                                                      submission_document.ccms_document_id,
                                                      Base64.strict_encode64(pdf_binary(submission_document)),
                                                      submission.legal_aid_application.provider.username,
                                                      submission_document.document_type)
      end

      def pdf_binary(submission_document)
        Attachment.find(submission_document.attachment_id).document.download
      end

      def update_document_status_and_return_response(document, document_upload_requestor)
        tx_id = document_upload_requestor.transaction_request_id
        response = document_upload_requestor.call
        document.status = if document_upload_response_parser(tx_id, response)
                            :uploaded
                          else
                            :failed
                          end
        response
      end

      def document_upload_response_parser(tx_id, response)
        CCMS::Parsers::DocumentUploadResponseParser
          .new(tx_id, response).success?
      end
    end
  end
end
