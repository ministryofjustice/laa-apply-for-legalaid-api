module Reports
  class BaseReportCreator
    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    attr_reader :legal_aid_application

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    private

    def pdf_report
      WickedPdf.new.pdf_from_string(html_report)
    end

    def ensure_case_ccms_reference_exists
      return if legal_aid_application.case_ccms_reference

      legal_aid_application.create_ccms_submission unless legal_aid_application.ccms_submission
      process_ccms_submission
    end

    def process_ccms_submission
      legal_aid_application.ccms_submission.process!
    end

    def html_report; end

    def default_url_options
      {
        _recall: {
          legal_aid_application_id: legal_aid_application.id
        }
      }
    end
  end
end
