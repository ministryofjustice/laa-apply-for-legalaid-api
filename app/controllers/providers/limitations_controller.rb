module Providers
  class LimitationsController < ProviderBaseController
    include PreDWPCheckVisible

    def show
      @form = LegalAidApplications::EmergencyCostOverrideForm.new(model: legal_aid_application)
      update_df_dates
      legal_aid_application.enter_applicant_details! unless legal_aid_application.entering_applicant_details?
    end

    def update
      if @legal_aid_application.used_delegated_functions?
        clear_limit_and_reason
        @form = LegalAidApplications::EmergencyCostOverrideForm.new(form_params)
        render :show unless save_continue_or_draft(@form)
      else
        continue_or_draft
      end
    end

    private

    # This is a little hack to ensure that df dates are copied to the application proceeding type
    # in the lead-up to switching over to multiple proceedings.  It's done here so that it's after
    # all the checks that are carried out on older df dates

    # TODO: remove once multiple proceedings has been implemented

    def update_df_dates
      return if Setting.allow_multiple_proceedings?

      apt = legal_aid_application.application_proceeding_types.first
      apt.update!(used_delegated_functions_on: legal_aid_application.used_delegated_functions_on,
                  used_delegated_functions_reported_on: legal_aid_application.used_delegated_functions_reported_on)
    end

    def clear_limit_and_reason
      atc = params[:legal_aid_application]
      return unless atc[:emergency_cost_override].to_s == 'false'

      atc[:emergency_cost_requested] = nil
      atc[:emergency_cost_reasons] = nil
    end

    def form_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:emergency_cost_override, :emergency_cost_requested, :emergency_cost_reasons)
      end
    end
  end
end
