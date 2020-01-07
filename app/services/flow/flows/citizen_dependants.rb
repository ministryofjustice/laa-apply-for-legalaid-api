# :nocov:
module Flow
  module Flows
    class CitizenDependants < FlowSteps
      STEPS = {
        has_dependants: {
          path: ->(_) { urls.citizens_has_dependants_path },
          forward: ->(application) { application.has_dependants? ? :dependants : :identify_types_of_outgoings }
        },
        dependants: {
          path: ->(_) { urls.citizens_dependants_path },
          forward: ->(_, dependant) { dependant.over_fifteen? ? :dependants_relationships : :has_other_dependants }
        },
        dependants_details: {
          forward: ->(_, dependant) { dependant.over_fifteen? ? :dependants_relationships : :has_other_dependants }
        },
        dependants_relationships: {
          path: ->(_, dependant) { urls.citizens_dependant_relationship_path(dependant) },
          forward: ->(_, dependant) do
            dependant.adult_relative? || dependant.eighteen_or_less? ? :dependants_monthly_incomes : :dependants_full_time_educations
          end
        },
        dependants_assets_values: {
          path: ->(_, dependant) { urls.citizens_dependant_assets_value_path(dependant) },
          forward: :has_other_dependants
        },
        dependants_monthly_incomes: {
          path: ->(_, dependant) { urls.citizens_dependant_monthly_income_path(dependant) },
          forward: ->(_, dependant) do
            dependant.in_full_time_education? || dependant.eighteen_or_less? ? :has_other_dependants : :dependants_assets_values
          end
        },
        has_other_dependants: {
          path: ->(_) { urls.citizens_has_other_dependant_path },
          forward: ->(_, has_other_dependant) { has_other_dependant ? :dependants : :identify_types_of_outgoings }
        },
        dependants_full_time_educations: {
          path: ->(_, dependant) { urls.citizens_dependant_full_time_education_path(dependant) },
          forward: :dependants_monthly_incomes
        }
      }.freeze
    end
  end
end
# :nocov:
