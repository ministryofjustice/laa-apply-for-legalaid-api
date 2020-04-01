namespace :ccms do
  desc 'Clear CCMS submissions with stuck means reports'
  task clear_queue: :environment do
    include Rails.application.routes.url_helpers

    dry_run = ENV['DRY_RUN'].nil?

    # v3
    # get the application_ids
    # delete any application.attachments where attachment_type='means_report'
    # delete any application.ccms_submission.submission_documents where document_type: "means_report"
    # run MeansReportCreator.call(legal_aid_application)
    # output url for accessing the means report e.g. service_url/application_guid/means_report

    application_ids = CCMS::Submission.where("aasm_state NOT IN ('completed', 'failed')").pluck(:legal_aid_application_id)
    application_ids.each do |laa_id|
      laa = LegalAidApplication.find(laa_id)
      attachments = laa.attachments.where(attachment_type: 'means_report')
      submission_documents = laa.ccms_submission.submission_documents.where(document_type: 'means_report')
      if dry_run
        pp "I want to delete the #{attachments.count} attachments with ids #{attachments.pluck(:id)}"
        pp "I want to delete the #{submission_documents.count} submission_documents with ids #{submission_documents.pluck(:id)}"
      else
        submission_documents.delete_all
        attachments.delete_all
      end
      Reports::MeansReportCreator.call(laa) unless dry_run
      laa.ccms_submission.complete! unless dry_run
      pp "#{providers_legal_aid_application_means_report_url(laa)}?debug=true#{' would work if not in dry_run mode' if dry_run}"
    rescue StandardError => e
      puts e
      raise
    end
  end
end
