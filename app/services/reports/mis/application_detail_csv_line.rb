module Reports
  module MIS
    class ApplicationDetailCsvLine
      include Sanitisable

      attr_reader :laa

      delegate :application_ref,
               :benefit_check_result,
               :ccms_submission,
               :created_at,
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
               :shared_ownership,
               :used_delegated_functions?,
               :used_delegated_functions_on,
               :used_delegated_functions_reported_on,
               :vehicle, to: :laa

      delegate :chances_of_success, to: :laa

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
               :proceedings_before_the_court,
               :details_of_proceedings_before_the_court,
               :pretty_success_prospect,
               :success_prospect_details,
               :statement_of_case_uploaded?,
                to: :chances_of_success

      delegate :firm,
               :username, to: :provider

      def self.header_row
        [
          'Firm name',
          'User name',
          'Office ID',
          'Apply reference number',
          'CCMS reference number',
          'Matter type',
          'Proceeding type selected',
          'DWP check result',
          'Delegated functions used',
          'Delegated functions date',
          'Delegated functions reported',
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
        dwp_check_result
        delegated_functions
        main_home_details
        vehicle_details
        savings_and_investment_details
        other_assets_details
        restrictions
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
        @line << application_ref
        @line << case_ccms_reference
      end

      def proceeding_details
        @line << proceeding_types.map(&:ccms_matter).sort.join(', ')
        @line << proceeding_types.map(&:meaning).sort.join(', ')
      end

      def dwp_check_result
        @line << benefit_check_result.result == 'Yes' ? 'Passported' : 'Non-passported'
      end

      def delegated_functions
        @line << yesno(used_delegated_functions?)
        @line << (used_delegated_functions? ? used_delegated_functions_on&.strftime('%Y-%m-%d') : '')
        @line << (used_delegated_functions? ? used_delegated_functions_reported_on&.strftime('%Y-%m-%d') : '')
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
        @line << pretty_success_prospect
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
    end
  end
end
