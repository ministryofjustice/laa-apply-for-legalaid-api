module Providers
  class MeritsReportsController < ProviderBaseController
    authorize_with_policy_method :show_submitted_application?
    def show
      @application_proceeding_type = legal_aid_application.lead_application_proceeding_type
      render pdf: 'Merit report',
             layout: 'pdf',
             show_as_html: params.key?(:debug)
    end
  end
end
