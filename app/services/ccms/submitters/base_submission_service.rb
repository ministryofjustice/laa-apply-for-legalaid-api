module CCMS
  module Submitters
    class BaseSubmissionService
      attr_accessor :submission

      CCMS_SUBMISSION_ERRORS = [
        CCMSError,
        CCMSUnsuccessfulResponseError,
        Savon::HTTPError,
        Savon::SOAPFault,
        Savon::Error,
        StandardError
      ].freeze

      def initialize(submission)
        @submission = submission
      end

      def self.call(*args)
        new(*args).call
      end

      private

      def create_history(from_state, to_state, xml_request, xml_response)
        SubmissionHistory.create submission: submission,
                                 from_state: from_state,
                                 to_state: to_state,
                                 success: true,
                                 request: xml_request,
                                 response: xml_response
      end

      def create_ccms_failure_history(from_state, error, xml_request, response: nil)
        SubmissionHistory.create submission: submission,
                                 from_state: from_state,
                                 to_state: :failed,
                                 success: false,
                                 request: xml_request,
                                 details: error.is_a?(Exception) ? format_exception(error) : error,
                                 response: response
      end

      def format_exception(error)
        [error.class, error.message, error.backtrace].flatten.join("\n")
      end

      def handle_exception(exception, xml_request, response: nil)
        create_ccms_failure_history(submission.aasm_state, exception, xml_request, response: response)
      end
    end
  end
end
