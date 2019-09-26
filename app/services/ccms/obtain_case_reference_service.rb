module CCMS
  class ObtainCaseReferenceService < BaseSubmissionService
    def call
      submission.case_ccms_reference = reference_id
      create_history(:initialised, submission.aasm_state, reference_data_requestor.formatted_xml) if submission.obtain_case_ref!
    rescue CcmsError => e
      handle_failure(e, reference_data_requestor.formatted_xml)
    end

    def reference_id
      ReferenceDataResponseParser.new(transaction_request_id, response).reference_id
    end

    def response
      reference_data_requestor.call
    end

    def transaction_request_id
      reference_data_requestor.transaction_request_id
    end

    private

    def reference_data_requestor
      @reference_data_requestor ||= ReferenceDataRequestor.new
    end
  end
end
