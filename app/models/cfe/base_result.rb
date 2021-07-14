module CFE
  class BaseResult < ApplicationRecord # rubocop:disable Metrics/ClassLength
    belongs_to :legal_aid_application
    belongs_to :submission

    MAX_VALUE = 999_999_999_999

    self.table_name = 'cfe_results'

    def result_hash
      JSON.parse(result, symbolize_names: true)
    end

    def overview
      return 'manual_check_required' if manual_check_required? && legal_aid_application.has_restrictions

      return determine_type_of_contribution if assessment_result == 'contribution_required'

      assessment_result
    end

    # alias contribution_required? capital_contribution_required?

    def eligible?
      assessment_result == 'eligible'
    end

    def partially_eligible?
      assessment_result == 'partially_eligible'
    end

    def version_4?
      result_hash[:version] == '4'
    end

    ################################################################
    #                                                              #
    #  MAIN HOME VALUES                                            #
    #                                                              #
    ################################################################

    def main_home_value
      main_home[:value]&.to_d
    end

    def main_home_outstanding_mortgage
      -1 * main_home[:allowable_outstanding_mortgage]&.to_d
    end

    def main_home_transaction_allowance
      -1 * main_home[:transaction_allowance]&.to_d
    end

    def main_home_equity_disregard
      -1 * main_home[:main_home_equity_disregard]&.to_d
    end

    def main_home_assessed_equity
      assessed_equity = main_home[:assessed_equity]&.to_d
      assessed_equity.positive? ? assessed_equity : 0.0
    end

    ################################################################
    #                                                              #
    #  ADDITIONAL PROPERTY                                         #
    #                                                              #
    ################################################################

    def additional_property?
      existing_and_not_all_zero?(property[:additional_properties].first)
    end

    def additional_property
      additional_properties.first
    end

    def additional_property_value
      additional_property[:value]&.to_d
    end

    def additional_property_transaction_allowance
      -1 * additional_property[:transaction_allowance]&.to_d
    end

    def additional_property_mortgage
      -1 * additional_property[:allowable_outstanding_mortgage]&.to_d
    end

    def additional_property_assessed_equity
      assessed_equity = additional_property[:assessed_equity]&.to_d
      assessed_equity.positive? ? assessed_equity : 0.0
    end

    ################################################################
    #                                                              #
    #  VEHICLE                                                     #
    #                                                              #
    ################################################################

    def vehicle_loan_amount_outstanding
      vehicle[:loan_amount_outstanding]&.to_d
    end

    def vehicle_disregard
      vehicle_value - vehicle_assessed_amount
    end

    def vehicle_assessed_amount
      vehicle[:assessed_value]&.to_d
    end

    ################################################################
    #                                                              #
    #  TOTALS                                                      #
    #                                                              #
    ################################################################

    def pensioner_capital_disregard
      if version_4?
        -1 * capital_summary[:pensioner_capital_disregard]&.to_d
      else
        -1 * capital[:pensioner_capital_disregard]&.to_d
      end
    end

    def total_capital_before_pensioner_disregard
      total_property + total_savings + total_vehicles + total_other_assets
    end

    def total_disposable_capital
      [0, (total_capital_before_pensioner_disregard + pensioner_capital_disregard)].max
    end

    ################################################################
    #                                                              #
    #  UTILITY METHODS                                             #
    #                                                              #
    ################################################################

    def existing_and_not_all_zero?(property)
      return false if property.nil?

      property_value = property[:value]&.to_d
      property.present? && property_value > 0.0
    end

    private

    def manual_check_required?
      CCMS::ManualReviewDeterminer.new(legal_aid_application).manual_review_required?
    end

    def determine_type_of_contribution
      return 'capital_and_income_contribution_required' if capital_contribution_required? && income_contribution_required?

      return 'capital_contribution_required' if capital_contribution_required?

      'income_contribution_required'
    end
  end
end
