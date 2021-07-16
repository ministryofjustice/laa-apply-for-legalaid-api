module Flow
  module Flows
    class ProviderStart < FlowSteps # rubocop:disable Metrics/ClassLength
      STEPS = {
        providers_home: {
          path: ->(_application) { urls.providers_legal_aid_applications_path }
        },
        applicants: {
          path: ->(_) { urls.new_providers_applicant_path },
          forward: :address_lookups
        },
        applicant_details: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_details_path(application) },
          forward: ->(application) do
            if application.applicant_details_checked?
              :check_provider_answers
            else
              :address_lookups
            end
          end,
          check_answers: :check_provider_answers
        },
        address_lookups: {
          path: ->(application) { urls.providers_legal_aid_application_address_lookup_path(application) },
          forward: :address_selections,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true
        },
        address_selections: {
          path: ->(application) { urls.providers_legal_aid_application_address_selection_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers
        },
        addresses: {
          path: ->(application) { urls.providers_legal_aid_application_address_path(application) },
          forward: :proceedings_types,
          check_answers: :check_provider_answers
        },
        proceedings_types: {
          path: ->(application) { urls.providers_legal_aid_application_proceedings_types_path(application) },
          forward: ->(application) do
            if Setting.allow_multiple_proceedings?
              :has_other_proceedings
            else
              application.checking_answers? ? :limitations : :used_delegated_functions
            end
          end
        },
        has_other_proceedings: {
          path: ->(application) { urls.providers_legal_aid_application_has_other_proceedings_path(application) },
          forward: ->(application, has_other_proceeding) do
            if has_other_proceeding
              :proceedings_types
            else
              application.section_8_proceedings? ? :in_scope_of_laspos : :used_multiple_delegated_functions
            end
          end
        },
        in_scope_of_laspos: {
          path: ->(application) { urls.providers_legal_aid_application_in_scope_of_laspo_path(application) },
          forward: :used_multiple_delegated_functions,
          carry_on_sub_flow: true,
          check_answers: :check_provider_answers
        },
        used_multiple_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_used_multiple_delegated_functions_path(application) },
          forward: ->(_application, delegated_functions_used_over_month_ago) do
            delegated_functions_used_over_month_ago ? :confirm_multiple_delegated_functions : :limitations
          end,
          check_answers: :check_provider_answers,
          carry_on_sub_flow: true
        },
        confirm_multiple_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_multiple_delegated_functions_path(application) },
          forward: ->(_application, confirmed_dates) do
            confirmed_dates ? :limitations : :used_multiple_delegated_functions
          end
        },
        used_delegated_functions: {
          path: ->(application) { urls.providers_legal_aid_application_used_delegated_functions_path(application) },
          forward: ->(application) do
            application.used_delegated_functions_within_year ? :confirm_delegated_functions_dates : :limitations
          end
        },
        confirm_delegated_functions_dates: {
          path: ->(application) { urls.providers_legal_aid_application_confirm_delegated_functions_date_path(application) },
          forward: :limitations
        },
        limitations: {
          path: ->(application) { urls.providers_legal_aid_application_limitations_path(application) },
          forward: :check_provider_answers
        },
        check_provider_answers: {
          path: ->(application) { urls.providers_legal_aid_application_check_provider_answers_path(application) },
          forward: :check_benefits
        },
        check_benefits: {
          path: ->(application) { urls.providers_legal_aid_application_check_benefits_path(application) },
          forward: ->(application, dwp_override_non_passported) do
            if application.applicant_receives_benefit?
              application.change_state_machine_type('PassportedStateMachine')
              application.used_delegated_functions? ? :substantive_applications : :capital_introductions
            else
              application.change_state_machine_type('NonPassportedStateMachine')
              dwp_override_non_passported ? :confirm_dwp_non_passported_applications : :applicant_employed
            end
          end
        },
        substantive_applications: {
          path: ->(application) { urls.providers_legal_aid_application_substantive_application_path(application) },
          forward: ->(application) do
            return :delegated_confirmation unless application.substantive_application?

            application.applicant_receives_benefit? ? :capital_introductions : :non_passported_client_instructions
          end
        },
        delegated_confirmation: {
          path: ->(application) { urls.providers_legal_aid_application_delegated_confirmation_index_path(application) }
        },
        applicant_employed: {
          path: ->(application) { urls.providers_legal_aid_application_applicant_employed_index_path(application) },
          forward: ->(application) do
            application.applicant_employed? ? :use_ccms_employed : :open_banking_consents
          end
        },
        open_banking_consents: {
          path: ->(application) { urls.providers_legal_aid_application_open_banking_consents_path(application) },
          forward: ->(application) do
            next_step = :non_passported_client_instructions
            next_step = :substantive_applications if application.applicant_employed? == false && application.used_delegated_functions?

            application.provider_received_citizen_consent? ? next_step : :use_ccms
          end
        },
        email_addresses: {
          path: ->(application) { urls.providers_legal_aid_application_email_address_path(application) },
          forward: :about_the_financial_assessments
        },
        about_the_financial_assessments: {
          path: ->(application) { urls.providers_legal_aid_application_about_the_financial_assessment_path(application) },
          forward: :application_confirmations
        },
        application_confirmations: {
          path: ->(application) { urls.providers_legal_aid_application_application_confirmation_path(application) }
        },
        use_ccms: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_path(application) }
        },
        delete: {
          path: ->(application) { urls.providers_legal_aid_application_delete_path(application) }
        },
        use_ccms_employed: {
          path: ->(application) { urls.providers_legal_aid_application_use_ccms_employed_index_path(application) }
        },
        non_passported_client_instructions: {
          path: ->(application) { urls.providers_legal_aid_application_non_passported_client_instructions_path(application) },
          forward: :email_addresses
        }
      }.freeze
    end
  end
end
