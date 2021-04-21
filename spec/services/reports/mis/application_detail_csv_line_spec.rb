require 'rails_helper'

module Reports
  module MIS
    RSpec.describe ApplicationDetailCsvLine do
      let(:legal_aid_application) do
        create :application,
               application_ref: 'L-X99-ZZZ',
               applicant: applicant,
               own_home: own_home_status,
               property_value: property_value,
               shared_ownership: shared_ownership_status,
               outstanding_mortgage_amount: outstanding_mortgage,
               percentage_home: percentage_home,
               provider: provider,
               office: office,
               benefit_check_result: benefit_check_result,
               savings_amount: savings_amount,
               other_assets_declaration: other_assets_declaration,
               opponent: opponent,
               proceeding_types: proceeding_types,
               ccms_submission: ccms_submission,
               application_proceeding_types: [application_proceeding_type],
               used_delegated_functions: used_delegated_functions,
               used_delegated_functions_on: used_delegated_functions_on,
               used_delegated_functions_reported_on: used_delegated_functions_reported_on,
               own_vehicle: false,
               merits_submitted_at: Time.current
      end

      let(:application_proceeding_type) do
        create :application_proceeding_type, chances_of_success: chances_of_success
      end

      let(:applicant) do
        create :applicant,
               first_name: 'Johnny',
               last_name: 'WALKER',
               date_of_birth: date_of_birth,
               national_insurance_number: 'JA293483A'
      end

      let(:provider) do
        create :provider,
               username: 'psr001',
               firm: firm
      end

      let(:firm) { create :firm, name: 'Legal beagles' }

      let(:office) { create :office, code: '1T823E' }

      let(:ccms_submission) { create :ccms_submission, case_ccms_reference: case_ccms_reference }

      let(:benefit_check_result) { create :benefit_check_result, result: benefit_check_result_text }

      let(:savings_amount) do
        create :savings_amount,
               offline_current_accounts: current_acct_val,
               offline_savings_accounts: savings_acct_val,
               cash: cash_val,
               other_person_account: third_pty_val,
               national_savings: nsi_val,
               plc_shares: plc_val,
               peps_unit_trusts_capital_bonds_gov_stocks: bonds_val,
               life_assurance_endowment_policy: la_val,
               none_selected: none_selected
      end

      let(:other_assets_declaration) do
        create :other_assets_declaration,
               second_home_value: second_home_value,
               second_home_mortgage: second_home_mortgage,
               second_home_percentage: second_home_percentage,
               timeshare_property_value: timeshare_property_value,
               land_value: land_value,
               valuable_items_value: valuable_items_value,
               inherited_assets_value: inherited_assets_value,
               money_owed_value: money_owed_value,
               trust_value: trust_value,
               none_selected: none_selected
      end

      let(:opponent) do
        create :opponent,
               understands_terms_of_court_order: understands_terms_of_court_order,
               understands_terms_of_court_order_details: understands_terms_of_court_order_details,
               warning_letter_sent: warning_letter_sent,
               warning_letter_sent_details: warning_letter_sent_details,
               police_notified: police_notified,
               police_notified_details: police_notified_details,
               bail_conditions_set: bail_conditions_set,
               bail_conditions_set_details: bail_conditions_set_details
      end

      let(:chances_of_success) do
        create :chances_of_success,
               success_prospect: prospect,
               application_purpose: purpose
      end

      let(:proceeding_types) { [proceeding_type] }
      let(:proceeding_type) do
        create :proceeding_type,
               meaning: 'Proceeding type meaning',
               description: 'Proceeding type description',
               ccms_matter: 'Matter type'
      end

      let(:case_ccms_reference) { '42226668880' }
      let(:date_of_birth) { Date.new(2004, 8, 12) }
      let(:own_home_status) { 'mortgage' }
      let(:property_value) { 876_200 }
      let(:shared_ownership_status) { 'partner_or_ex_partner' }
      let(:outstanding_mortgage) { 397_822 }
      let(:percentage_home) { 50 }
      let(:benefit_check_result_text) { 'Yes' }
      let(:current_acct_val) { 25.44 }
      let(:savings_acct_val) { 266.10 }
      let(:cash_val) { 17 }
      let(:third_pty_val) { 127 }
      let(:nsi_val) { 5 }
      let(:plc_val) { 120 }
      let(:bonds_val) { 374.22 }
      let(:la_val) { 1102.22 }
      let(:none_selected) { nil }

      let(:second_home_value) { 156_000 }
      let(:second_home_mortgage) { 56_000 }
      let(:second_home_percentage) { 50 }
      let(:timeshare_property_value) { 120_555 }
      let(:land_value) { 55_00 }
      let(:valuable_items_value) { 600 }
      let(:inherited_assets_value) { 300 }
      let(:money_owed_value) { 25 }
      let(:trust_value) { 99 }
      let(:none_selected) { nil }

      let(:understands_terms_of_court_order) { true }
      let(:understands_terms_of_court_order_details) { 'Understood' }
      let(:warning_letter_sent) { true }
      let(:warning_letter_sent_details) { 'This is a warning' }
      let(:police_notified) { true }
      let(:police_notified_details) { 'Police notified' }
      let(:bail_conditions_set) { true }
      let(:bail_conditions_set_details) { 'On bail' }

      let(:prospect) { 'likely' }
      let(:purpose) { 'The reason we are applying' }
      let(:submitted_at) { Time.zone.local(2020, 2, 21, 15, 44, 55) }
      let(:used_delegated_functions) { true }
      let(:used_delegated_functions_on) { Date.new(2020, 1, 1) }
      let(:used_delegated_functions_on_date) { Date.new(2020, 2, 21) }
      let(:used_delegated_functions_reported_on) { Date.new(2020, 2, 21) }

      describe '.call' do
        let(:headers) { described_class.header_row }
        let(:data_row) { described_class.call(legal_aid_application) }

        context 'application and provider details' do
          it 'returns the correct values' do
            expect(value_for('Firm name')).to eq 'Legal beagles'
            expect(value_for('User name')).to eq 'psr001'
            expect(value_for('Office ID')).to eq '1T823E'
            expect(value_for('Apply reference number')).to eq 'L-X99-ZZZ'
            expect(value_for('CCMS reference number')).to eq '42226668880'
            expect(value_for('Matter type')).to eq 'Matter type'
            expect(value_for('Proceeding type selected')).to eq 'Proceeding type meaning'
            expect(value_for('DWP check result')).to eq 'Yes'
            expect(value_for('Delegated functions used')).to eq 'Yes'
            expect(value_for('Delegated functions date')).to eq '2020-01-01'
            expect(value_for('Delegated functions reported')).to eq '2020-02-21'
          end

          context 'DWP check result negative' do
            let(:benefit_check_result_text) { 'No' }
            it 'generates no' do
              expect(value_for('DWP check result')).to eq 'No'
            end
          end

          context 'Delegated functions not used' do
            let(:used_delegated_functions) { false }
            let(:used_delegated_functions_on) { nil }

            it 'generates no' do
              expect(value_for('Delegated functions used')).to eq 'No'
            end

            it 'generates an empty string for the used_on date' do
              expect(value_for('Delegated functions date')).to eq ''
            end

            it 'generates an empty string for the delegated function notification date' do
              expect(value_for('Delegated functions reported')).to eq ''
            end
          end
        end

        context 'own home' do
          context 'with own home' do
            it 'generates the expected values' do
              expect(value_for('Own home?')).to eq 'mortgage'
              expect(value_for('Value')).to eq 876_200
              expect(value_for('Outstanding mortgage')).to eq 397_822
              expect(value_for('Shared?')).to eq 'partner_or_ex_partner'
              expect(value_for('%age owned')).to eq 50
            end

            context 'own home not shared' do
              let(:shared_ownership_status) { 'no_sole_owner' }
              it 'generates values for home not shared' do
                expect(value_for('Own home?')).to eq 'mortgage'
                expect(value_for('Value')).to eq 876_200
                expect(value_for('Outstanding mortgage')).to eq 397_822
                expect(value_for('Shared?')).to eq 'no_sole_owner'
                expect(value_for('%age owned')).to eq ''
              end
            end

            context 'home owned outright' do
              let(:shared_ownership_status) { 'no_sole_owner' }
              let(:own_home_status) { 'owned_outright' }
              it 'generates values for home not shared' do
                expect(value_for('Own home?')).to eq 'owned_outright'
                expect(value_for('Value')).to eq 876_200
                expect(value_for('Outstanding mortgage')).to eq ''
                expect(value_for('Shared?')).to eq 'no_sole_owner'
                expect(value_for('%age owned')).to eq ''
              end
            end
          end
        end

        context 'vehicle' do
          context 'no vehicle' do
            it 'generates blank fields' do
              expect(value_for('Vehicle?')).to eq 'No'
              expect(value_for('Vehicle value')).to eq ''
              expect(value_for('Outstanding loan?')).to eq ''
              expect(value_for('Loan remaining')).to eq ''
              expect(value_for('Date purchased')).to eq ''
              expect(value_for('In Regular use?')).to eq ''
            end
          end

          context 'vehicle' do
            let!(:vehicle) do
              create :vehicle,
                     legal_aid_application: legal_aid_application,
                     estimated_value: 12_000,
                     payment_remaining: payment_remaining,
                     used_regularly: used_regularly,
                     purchased_on: purchase_date
            end
            let(:purchase_date) { Date.new(2020, 1, 1) }
            let(:used_regularly) { true }

            context 'in regular use, no loan outstanding' do
              let(:payment_remaining) { 0 }
              it 'generates the values' do
                expect(value_for('Vehicle?')).to eq 'Yes'
                expect(value_for('Vehicle value')).to eq 12_000
                expect(value_for('Outstanding loan?')).to eq 'No'
                expect(value_for('Loan remaining')).to eq ''
                expect(value_for('Date purchased')).to eq '2020-01-01'
                expect(value_for('In Regular use?')).to eq 'Yes'
              end
            end

            context 'not in regular use' do
              let(:used_regularly) { false }
              let(:payment_remaining) { 0 }
              it 'generates the values' do
                expect(value_for('Vehicle?')).to eq 'Yes'
                expect(value_for('Vehicle value')).to eq 12_000
                expect(value_for('Outstanding loan?')).to eq 'No'
                expect(value_for('Loan remaining')).to eq ''
                expect(value_for('Date purchased')).to eq '2020-01-01'
                expect(value_for('In Regular use?')).to eq 'No'
              end
            end

            context 'loan outstanding' do
              let(:payment_remaining) { 4_566 }
              it 'generates the values' do
                expect(value_for('Vehicle?')).to eq 'Yes'
                expect(value_for('Vehicle value')).to eq 12_000
                expect(value_for('Outstanding loan?')).to eq 'Yes'
                expect(value_for('Loan remaining')).to eq 4_566
                expect(value_for('Date purchased')).to eq '2020-01-01'
                expect(value_for('In Regular use?')).to eq 'Yes'
              end
            end
          end

          context 'savings_amount' do
            context 'savings amount record does not exist' do
              it 'generates nos and blanks' do
                legal_aid_application.update! savings_amount: nil
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'No' }
                savings_amount_value_attrs.each { |attr| expect(value_for(attr)).to eq '' }
              end
            end

            context 'savings amount record is all nils' do
              it 'generates nos and blanks' do
                legal_aid_application.update! savings_amount: create(:savings_amount, :all_nil)
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'No' }
                savings_amount_value_attrs.each { |attr| expect(value_for(attr)).to eq '' }
              end
            end
            context 'savings amount record is all zeros' do
              it 'generates Yes and zero for each attr' do
                legal_aid_application.update! savings_amount: create(:savings_amount, :all_zero)
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'Yes' }
                savings_amount_value_attrs.each { |attr| expect(value_for(attr)).to eq 0.0 }
              end
            end

            context 'savings amount record is populated' do
              it 'generates the correct values' do
                savings_amount_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'Yes' }
                expect(value_for('Current acct value')).to eq savings_amount.offline_current_accounts
                expect(value_for('Savings acct value')).to eq savings_amount.offline_savings_accounts
                expect(value_for('Cash value')).to eq savings_amount.cash
                expect(value_for('Third party acct value')).to eq savings_amount.other_person_account
                expect(value_for('NSI and PB value')).to eq savings_amount.national_savings
                expect(value_for('PLC shares value')).to eq savings_amount.plc_shares
                expect(value_for('Govt. stocks, bonds value')).to eq savings_amount.peps_unit_trusts_capital_bonds_gov_stocks
                expect(value_for('Life assurance value')).to eq savings_amount.life_assurance_endowment_policy
              end
            end
          end
        end

        context 'other_assets declaration' do
          context 'does not exist' do
            it 'generates Nos and blanks' do
              legal_aid_application.update! other_assets_declaration: nil
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'No' }
              other_assets_value_attrs.each { |attr| expect(value_for(attr)).to eq '' }
            end
          end

          context 'other assets declaration is all nils' do
            it 'generates Nos and blanks' do
              legal_aid_application.update! other_assets_declaration: create(:other_assets_declaration, :all_nil)
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'No' }
              other_assets_value_attrs.each { |attr| expect(value_for(attr)).to eq '' }
            end
          end

          context 'other assets declaration is all zero' do
            it 'generates yes and zero' do
              legal_aid_application.update! other_assets_declaration: create(:other_assets_declaration, :all_zero)
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'Yes' }
              other_assets_value_attrs.each { |attr| expect(value_for(attr)).to eq 0.0 }
            end
          end

          context 'other assets declaration has values' do
            it 'generates the correct values' do
              other_assets_bool_attrs.each { |attr| expect(value_for(attr)).to eq 'Yes' }
              expect(value_for('Valuable items value')).to eq other_assets_declaration.valuable_items_value
              expect(value_for('Second home value')).to eq other_assets_declaration.second_home_value
              expect(value_for('Timeshare value')).to eq other_assets_declaration.timeshare_property_value
              expect(value_for('Land value')).to eq other_assets_declaration.land_value
              expect(value_for('Inheritance value')).to eq other_assets_declaration.inherited_assets_value
              expect(value_for('Money owed value')).to eq other_assets_declaration.money_owed_value
            end
          end
        end

        context 'restrictions' do
          context 'without restrictions' do
            it 'generates blanks' do
              expect(value_for('Restrictions?')).to eq 'No'
              expect(value_for('Restriction details')).to eq ''
            end
          end
          context 'with restrictions' do
            it 'generates yes and the details' do
              legal_aid_application.update(has_restrictions: true, restrictions_details: 'Bankrupt')
              expect(value_for('Restrictions?')).to eq 'Yes'
              expect(value_for('Restriction details')).to eq 'Bankrupt'
            end
          end
        end

        context 'opponent' do
          context 'no opponent record' do
            it 'generates blanks' do
              legal_aid_application.update! opponent: nil
              expect(value_for('Opponent can understand?')).to eq ''
              expect(value_for('Ability to understand details')).to eq ''
              expect(value_for('Warning letter sent?')).to eq ''
              expect(value_for('Warning letter details')).to eq ''
              expect(value_for('Police notified?')).to eq ''
              expect(value_for('Police notification details')).to eq ''
              expect(value_for('Bail conditions set?')).to eq ''
              expect(value_for('Bail details')).to eq ''
            end
          end

          context 'opponent record exists' do
            it 'generates the values' do
              expect(value_for('Opponent can understand?')).to eq 'Yes'
              expect(value_for('Ability to understand details')).to eq opponent.understands_terms_of_court_order_details
              expect(value_for('Warning letter sent?')).to eq 'Yes'
              expect(value_for('Warning letter details')).to eq opponent.warning_letter_sent_details
              expect(value_for('Police notified?')).to eq 'Yes'
              expect(value_for('Police notification details')).to eq opponent.police_notified_details
              expect(value_for('Bail conditions set?')).to eq 'Yes'
              expect(value_for('Bail details')).to eq opponent.bail_conditions_set_details
            end
          end

          context 'data begins with a vulnerable character' do
            before { firm.name = '=malicious_code' }
            it 'returns the escaped text' do
              expect(value_for('Firm name')).to eq "'=malicious_code"
            end
          end
        end
      end

      def value_for(name)
        data_row[headers.index(name)]
      end

      def savings_amount_bool_attrs
        [
          'Current acct?',
          'Savings acct?',
          'Cash?',
          'Third party acct?',
          'NSI and PB?',
          'PLC shares?',
          'Govt. stocks, bonds?, etc?',
          'Life assurance?'
        ]
      end

      def savings_amount_value_attrs
        [
          'Current acct value',
          'Savings acct value',
          'Cash value',
          'Third party acct value',
          'NSI and PB value',
          'PLC shares value',
          'Govt. stocks, bonds value',
          'Life assurance value'
        ]
      end

      def other_assets_bool_attrs
        [
          'Valuable items?',
          'Second home?',
          'Timeshare?',
          'Land?',
          'Inheritance?',
          'Money owed?'
        ]
      end

      def other_assets_value_attrs
        [
          'Valuable items value',
          'Second home value',
          'Timeshare value',
          'Land value',
          'Inheritance value',
          'Money owed value'
        ]
      end
    end
  end
end
