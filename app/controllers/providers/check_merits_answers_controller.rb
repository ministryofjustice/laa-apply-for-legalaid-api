module Providers
  class CheckMeritsAnswersController < ProviderBaseController
    def show
      legal_aid_application.create_opponent! unless legal_aid_application.opponent
      legal_aid_application.check_merits_answers! unless legal_aid_application.checking_merits_answers?
      application_proceeding_type
    end

    def continue
      unless draft_selected?
        legal_aid_application.generate_reports! if legal_aid_application.may_generate_reports?
        legal_aid_application.merits_complete!
      end
      continue_or_draft
    end

    def reset
      legal_aid_application.reset!
      redirect_to providers_application_proceeding_type_chances_of_success_index_path(application_proceeding_type)
    end

    private

    def application_proceeding_type
      @application_proceeding_type ||= legal_aid_application.lead_application_proceeding_type
    end
  end
end
