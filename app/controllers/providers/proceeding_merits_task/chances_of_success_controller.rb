module Providers
  module ProceedingMeritsTask
    class ChancesOfSuccessController < ProviderBaseController
      def index
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(model: chances_of_success)
      end

      def create
        @form = ChancesOfSuccesses::SuccessLikelyForm.new(form_params)

        return if save_continue_or_draft(@form)

        render :index
      end

      private

      def legal_aid_application
        @legal_aid_application ||= application_proceeding_type.legal_aid_application
      end

      def chances_of_success
        @chances_of_success ||= application_proceeding_type.chances_of_success || application_proceeding_type.build_chances_of_success
      end

      def application_proceeding_type
        @application_proceeding_type = ApplicationProceedingType.find(params[:application_proceeding_type_id])
      end

      def form_params
        merge_with_model(chances_of_success) do
          next {} unless params[:proceeding_merits_task_chances_of_success]

          params.require(:proceeding_merits_task_chances_of_success).permit(:success_likely)
        end
      end
    end
  end
end
