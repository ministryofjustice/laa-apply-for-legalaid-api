module Providers
  class LegalAidApplicationsController < ProviderBaseController
    legal_aid_application_not_required!

    # GET /provider/applications
    def index
      # TODO: Add pagination at some point
      @applications = current_provider.legal_aid_applications.latest.limit(10)
    end

    # POST /provider/applications
    def create
      @legal_aid_application = LegalAidApplication.create(provider: current_provider)
      go_forward
    end
  end
end
