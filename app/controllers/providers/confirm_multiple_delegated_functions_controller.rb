module Providers
  class ConfirmMultipleDelegatedFunctionsController < ProviderBaseController
    def show
      application_proceeding_types
      form
    end

    def update
      return continue_or_draft if draft_selected?

      application_proceeding_types
      return go_forward(form.confirm_multiple_delegated_functions_date?) if form.valid?

      render :show
    end

    private

    def form
      @form ||= BinaryChoiceForm.call(
        journey: :provider,
        radio_buttons_input_name: :confirm_multiple_delegated_functions_date,
        form_params: form_params,
        error: multiple_dates_check? ? 'error.blank_plural' : 'error.blank_singular'
      )
    end

    def multiple_dates_check?
      @multiple_dates_check ||= legal_aid_application.application_proceeding_types.uniq.select { |item| item.used_delegated_functions_on.present? }.many?
    end

    def application_proceeding_types
      @application_proceeding_types ||= legal_aid_application.application_proceedings_by_name
    end

    def form_params
      return {} unless params[:binary_choice_form]

      params.require(:binary_choice_form).permit(:confirm_multiple_delegated_functions_date)
    end
  end
end
