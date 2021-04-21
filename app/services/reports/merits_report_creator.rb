module Reports
  class MeritsReportCreator < BaseReportCreator
    def call
      return if legal_aid_application.merits_report

      attachment = legal_aid_application.attachments.create!(attachment_type: 'merits_report',
                                                             attachment_name: 'merits_report.pdf')

      attachment.document.attach(
        io: StringIO.new(pdf_report),
        filename: 'merits_report.pdf',
        content_type: 'application/pdf'
      )
    end

    private

    def html_report
      ensure_case_ccms_reference_exists

      Providers::MeritsReportsController.default_url_options = default_url_options

      Providers::MeritsReportsController.renderer.render(
        template: 'providers/merits_reports/show',
        layout: 'pdf',
        locals: {
          :@legal_aid_application => legal_aid_application,
          :@application_proceeding_type => legal_aid_application.lead_application_proceeding_type
        }
      )
    end
  end
end
