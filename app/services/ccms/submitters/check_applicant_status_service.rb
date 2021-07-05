module CCMS
  module Submitters
    class CheckApplicantStatusService < BaseSubmissionService
      def call
        tx_id = applicant_add_status_requestor.transaction_request_id
        submission.applicant_poll_count += 1
        submission.save!
        response = applicant_add_status_requestor.call
        parser = CCMS::Parsers::ApplicantAddStatusResponseParser.new(tx_id, response)
        process_response(parser)
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, xml_request)
        raise
      end

      private

      def process_response(parser) # rubocop:disable Metrics/AbcSize
        if parser.success?
          submission.applicant_ccms_reference = parser.applicant_ccms_reference
          create_history(:applicant_submitted, submission.aasm_state, xml_request, response) if submission.obtain_applicant_ref!
        elsif submission.applicant_poll_count >= Submission::POLL_LIMIT
          handle_exception('Poll limit exceeded', xml_request)
        else
          create_history(submission.aasm_state, submission.aasm_state, xml_request, response)
        end
      end

      def applicant_add_status_requestor
        @applicant_add_status_requestor ||= CCMS::Requestors::ApplicantAddStatusRequestor.new(submission.applicant_add_transaction_id,
                                                                                              submission.legal_aid_application.provider.username)
      end

      def response
        @response ||= applicant_add_status_requestor.call
      end

      def xml_request
        @xml_request ||= applicant_add_status_requestor.formatted_xml
      end
    end
  end
end
