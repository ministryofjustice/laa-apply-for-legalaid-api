module Reports
  module MIS
    class ApplicationDetailCsvLine
      include Sanitisable

      attr_reader :laa

      delegate :applicant_receives_benefit?,
               :application_proceeding_types,
               :cash_transactions,
               :ccms_submission,
               :cfe_result,
               :created_at,
               :dependants,
               :dwp_override,
               :emergency_cost_override?,
               :emergency_cost_requested,
               :involved_children,
               :irregular_incomes,
               :lead_application_proceeding_type,
               :office,
               :other_assets_declaration,
               :outstanding_mortgage_amount,
               :own_home,
               :percentage_home,
               :proceeding_types,
               :property_value,
               :provider,
               :opponent,
               :savings_amount,
               :merits_submitted_at,
               :policy_disregards,
               :shared_ownership,
               :statement_of_case_uploaded?,
               :used_delegated_functions?,
               :used_delegated_functions_on,
               :used_delegated_functions_reported_on,
               :lowest_prospect_of_success,
               :vehicle, to: :laa

      delegate :chances_of_success, to: :lead_application_proceeding_type

      delegate :case_ccms_reference, to: :ccms_submission

      delegate :offline_current_accounts,
               :offline_savings_accounts,
               :cash,
               :other_person_account,
               :national_savings,
               :peps_unit_trusts_capital_bonds_gov_stocks,
               :plc_shares,
               :life_assurance_endowment_policy, to: :savings_amount

      delegate :valuable_items_value,
               :second_home_value,
               :timeshare_property_value,
               :land_value,
               :inherited_assets_value,
               :money_owed_value, to: :other_assets_declaration

      delegate :understands_terms_of_court_order?,
               :understands_terms_of_court_order_details,
               :warning_letter_sent?,
               :warning_letter_sent_details,
               :police_notified?,
               :police_notified_details,
               :bail_conditions_set?,
               :bail_conditions_set_details, to: :opponent

      delegate :application_purpose,
               :success_prospect_details,
               to: :chances_of_success

      delegate :firm,
               :username, to: :provider

      def self.header_row
        [
          'Firm name',
          'User name',
          'Office ID',
          'CCMS reference number',
          'Single/Multi Proceedings'
          'Matter types',
          'No. of proceedings',
          'Proceeding types selected',
          'LASPO Question',
          'Case Type',
          'DWP Overridden',
          'Delegated functions used',
          'Delegated functions dates',
          'Delegated functions reported',
          'Requested higher limit?',
          'Limit requested',
          'Payments received in cash?',
          'Student finance received?',
          'Payments made in cash?',
          'Client has dependants?',
          'Disregarded income/capital?',
          'Own home?',
          'Value',
          'Outstanding mortgage',
          'Shared?',
          '%age owned',
          'Vehicle?',
          'Vehicle value',
          'Outstanding loan?',
          'Loan remaining',
          'Date purchased',
          'In Regular use?',
          'Current acct?',
          'Savings acct?',
          'Cash?',
          'Third party acct?',
          'NSI and PB?',
          'PLC shares?',
          'Govt. stocks, bonds?, etc?',
          'Life assurance?',
          'Current acct value',
          'Savings acct value',
          'Cash value',
          'Third party acct value',
          'NSI and PB value',
          'PLC shares value',
          'Govt. stocks, bonds value',
          'Life assurance value',
          'Valuable items?',
          'Second home?',
          'Timeshare?',
          'Land?',
          'Inheritance?',
          'Money owed?',
          'Valuable items value',
          'Second home value',
          'Timeshare value',
          'Land value',
          'Inheritance value',
          'Money owed value',
          'Restrictions?',
          'Restriction details',
          'Fully eligible (means)?',
          'Partially eligible (means)?',
          'Number of children involved',
          'Supporting evidence uploaded?',
          'Number of items of evidence',
          'Opponent can understand?',
          'Ability to understand details',
          'Warning letter sent?',
          'Warning letter details',
          'Police notified?',
          'Police notification details',
          'Bail conditions set?',
          'Bail details',
          'Prospects of success',
          'Prospects of success details',
          'SOC uploaded?',
          'Application started',
          'Application submitted'
        ]
      end

      def self.call(legal_aid_application)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        @laa = legal_aid_application
        @line = []
      end

      def call
        provider_firm_details
        application_details
        proceeding_details
        passported_check_result
        dwp_overridden
        delegated_functions
        income_details
        main_home_details
        vehicle_details
        savings_and_investment_details
        other_assets_details
        restrictions
        eligibility
        opponent_details
        merits
        sanitise
      end

      private

      def provider_firm_details
        @line << firm.name
        @line << username
        @line << office&.code
      end

      def application_details
        @line << case_ccms_reference
        @line << application_proceedig_types.count > 1 ? 'Multi' : 'Single'
      end

      def proceeding_details
        @line << proceeding_types.map(&:ccms_matter).sort.join(', ')
        @line << application_proceeding_types.count
        @line << proceeding_types.map(&:meaning).sort.join(', ')
        @line << laspo_question
      end

      def income_details
        @line << yesno(cash_transactions.credits.any?)
        @line << yesno(irregular_incomes.student_finance.any?)
        @line << yesno(cash_transactions.debits.any?)
        @line << yesno(dependants.any?)
        @line << yesno(policy_disregards.present?)
      end

      def passported_check_result
        @line << (applicant_receives_benefit? ? 'Passported' : 'Non-Passported')
      end

      def dwp_overridden
        @line << (dwp_override ? 'TRUE' : 'FALSE')
      end

      def delegated_functions
        @line << yesno(used_delegated_functions?)
        @line << application_proceeding_types.map(&:pretty_df_date).join(', ')
        @line << (used_delegated_functions? ? used_delegated_functions_reported_on&.strftime('%Y-%m-%d') : '')
      end

      def default_cost_overrride
        @line << yesno(emergency_cost_override?)
        @line << emergency_cost_requested
      end

      def main_home_details
        @line << own_home
        @line << (own_home == 'no' ? '' : property_value)
        @line << (own_home == 'mortgage' ? outstanding_mortgage_amount : '')
        @line << shared_ownership
        @line << (shared_ownership == 'no_sole_owner' ? '' : percentage_home)
      end

      def vehicle_details
        @line << yesno(vehicle.present?)
        vehicle.present? ? vehicle_attrs : @line += ['', '', '', '', '']
      end

      def vehicle_attrs # rubocop:disable Metrics/AbcSize
        @line << vehicle.estimated_value
        @line << (nil_or_zero?(vehicle.payment_remaining) ? 'No' : 'Yes')
        @line << (nil_or_zero?(vehicle.payment_remaining) ? '' : vehicle.payment_remaining)
        @line << vehicle.purchased_on&.strftime('%Y-%m-%d')
        @line << yesno(vehicle.used_regularly?)
      end

      def savings_and_investment_details
        if savings_amount.present?
          sandi_bools
          sandi_values
        else
          8.times { @line << 'No' }
          8.times { @line << '' }
        end
      end

      def sandi_attributes
        [
          offline_current_accounts,
          offline_savings_accounts,
          cash,
          other_person_account,
          national_savings,
          plc_shares,
          peps_unit_trusts_capital_bonds_gov_stocks,
          life_assurance_endowment_policy
        ]
      end

      def sandi_bools
        sandi_attributes.each { |attr| @line << yesno(attr.present?) }
      end

      def sandi_values
        sandi_attributes.each { |attr| @line << (attr.nil? ? '' : attr) }
      end

      def other_assets_details
        if other_assets_declaration.present?
          other_assets_bools
          other_assets_values
        else
          6.times { @line << 'No' }
          6.times { @line << '' }
        end
      end

      def other_assets_attributes
        [
          valuable_items_value,
          second_home_value,
          timeshare_property_value,
          land_value,
          inherited_assets_value,
          money_owed_value
        ]
      end

      def other_assets_bools
        other_assets_attributes.each { |attr| @line << yesno(attr.present?) }
      end

      def other_assets_values
        other_assets_attributes.each do |attr|
          @line << (attr.nil? ? '' : attr)
        end
      end

      def restrictions
        @line << yesno(laa.has_restrictions?)
        @line << (laa.has_restrictions? ? laa.restrictions_details : '')
      end

      def eligibility
        @line << yesno(cfe_result.eligible?)
        @line << yesno(cfe_result.partially_eligble?)
        @line << involved_children.count

        # 'Fully eligible (means)?',
        # 'Partially eligible (means)?',
        # 'Number of children involved',
        # 'Supporting evidence uploaded?',
        # 'Number of items of evidence',

      end

      def opponent_details
        opponent.present? ? opponent_attrs : 8.times { @line << '' }
      end

      def opponent_attrs # rubocop:disable Metrics/AbcSize
        @line << yesno(understands_terms_of_court_order?)
        @line << understands_terms_of_court_order_details
        @line << yesno(warning_letter_sent?)
        @line << warning_letter_sent_details
        @line << yesno(police_notified?)
        @line << police_notified_details
        @line << yesno(bail_conditions_set?)
        @line << bail_conditions_set_details
      end

      def merits
        @line << lowest_prospect_of_success
        @line << success_prospect_details
        @line << statement_of_case_uploaded?
        @line << created_at.strftime('%Y-%m-%d')
        @line << merits_submitted_at.strftime('%Y-%m-%d')
      end

      def yesno(value)
        value == true ? 'Yes' : 'No'
      end

      def nil_or_zero?(value)
        value.nil? || value.zero?
      end

      def laspo_question
        case @laa.in_scope_of_laspo
        when true
          'Yes'
        when false
          'No'
        else
          ''
        end
      end
    end
  end
end
