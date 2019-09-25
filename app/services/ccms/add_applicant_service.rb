module CCMS
  class AddApplicantService < BaseSubmissionService
    def call
      if applicant_add_response_parser.success?
        # binding.pry
        submission.applicant_add_transaction_id = applicant_add_requestor.transaction_request_id
        create_history('case_ref_obtained', submission.aasm_state, xml_request) if submission.submit_applicant!
      else
        handle_failure(response)
      end
    rescue CcmsError => e
      handle_failure(e)
    end

    private

    def applicant_add_requestor
      @applicant_add_requestor ||= ApplicantAddRequestor.new(legal_aid_application.applicant, legal_aid_application.provider.username)
    end

    def applicant_add_response_parser
      @applicant_add_response_parser ||= ApplicantAddResponseParser.new(applicant_add_requestor.transaction_request_id, response)
    end

    def xml_request
      @xml_request ||= applicant_add_requestor.formatted_xml
    end

    def response
      @response ||= applicant_add_requestor.call
    end

    def legal_aid_application
      submission.legal_aid_application
    end
  end
end
