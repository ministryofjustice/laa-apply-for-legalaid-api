module CCMS
  module Submitters
    class CheckCaseStatusService < BaseSubmissionService
      def call
        tx_id = case_add_status_requestor.transaction_request_id
        submission.case_poll_count += 1
        submission.save!
        parser = CCMS::Parsers::CaseAddStatusResponseParser.new(tx_id, response)
        process_response(parser)
      rescue *CCMS_SUBMISSION_ERRORS => e
        handle_exception(e, xml_request)
        raise
      end

      private

      def process_response(parser) # rubocop:disable Metrics/AbcSize
        if parser.success?
          create_history(:case_submitted, submission.aasm_state, xml_request, response) if submission.confirm_case_created!
        elsif submission.case_poll_count >= Submission::POLL_LIMIT
          handle_exception('Poll limit exceeded', xml_request)
        else
          create_history(submission.aasm_state, submission.aasm_state, xml_request, response)
        end
      end

      def case_add_status_requestor
        @case_add_status_requestor ||= CCMS::Requestors::CaseAddStatusRequestor.new(submission.case_add_transaction_id, submission.legal_aid_application.provider.username)
      end

      def response
        @response ||= case_add_status_requestor.call
      end

      def xml_request
        @xml_request ||= case_add_status_requestor.formatted_xml
      end
    end
  end
end
