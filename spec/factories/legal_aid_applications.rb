FactoryBot.define do
  factory :legal_aid_application, aliases: [:application] do
    provider
    used_delegated_functions { false }
    used_delegated_functions_on { nil }

    trait :with_applicant do
      # use :with_bank_accounts: 2 to create 2 bank accounts for the applicant
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build :applicant, with_bank_accounts: with_bank_accounts }
    end

    trait :with_applicant_and_address do
      transient do
        with_bank_accounts { 0 }
      end
      applicant { build :applicant, :with_address, with_bank_accounts: with_bank_accounts }
    end

    trait :with_applicant_and_address_lookup do
      applicant { build :applicant, :with_address_lookup }
    end

    #######################################################
    #        TRAITS TO SET STATE                          #
    #######################################################

    trait :with_non_passported_state_machine do
      before(:create) do |application|
        state_machine = FactoryBot.build(:non_passported_state_machine, legal_aid_application: application)
        application.update!(state_machine: state_machine)
      end
      non_passported
    end

    trait :with_passported_state_machine do
      before(:create) do |application|
        state_machine = FactoryBot.build(:passported_state_machine, legal_aid_application: application)
        application.update!(state_machine: state_machine)
      end
      passported
    end

    trait :initiated do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :initiated)
      end
    end

    trait :analysing_bank_transactions do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :analysing_bank_transactions)
      end
    end

    trait :awaiting_applicant do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :awaiting_applicant)
      end
    end

    trait :applicant_details_checked do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_details_checked)
      end
    end

    trait :applicant_entering_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_entering_means)
      end
    end

    trait :assessment_submitted do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :assessment_submitted)
      end
    end

    trait :awaiting_applicant do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :awaiting_applicant)
      end
    end

    trait :checking_applicant_details do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_applicant_details)
      end
    end

    trait :checking_citizen_answers do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_citizen_answers)
      end
    end

    trait :checking_merits_answers do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_merits_answers)
      end
    end

    trait :checking_non_passported_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_non_passported_means)
      end
    end

    trait :checking_passported_answers do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_passported_answers)
      end
    end

    trait :delegated_functions_used do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :delegated_functions_used)
      end
    end

    trait :entering_applicant_details do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :entering_applicant_details)
      end
    end

    trait :generating_reports do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :generating_reports)
      end
    end

    trait :provider_assessing_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_assessing_means)
      end
    end

    trait :provider_confirming_applicant_eligibility do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_confirming_applicant_eligibility)
      end
    end

    trait :provider_entering_means do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_entering_means)
      end
    end

    trait :provider_entering_merits do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_entering_merits)
      end
    end

    trait :submitting_assessment do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :submitting_assessment)
      end
    end

    trait :use_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :unknown)
      end
    end

    trait :use_ccms_employed do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :employed)
      end
    end

    trait :use_ccms_no_banking_consent do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :no_banking_consent)
      end
    end

    trait :use_ccms_offline_accounts do
      before(:create) do |application|
        application.change_state_machine_type('NonPassportedStateMachine')
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :offline_accounts)
      end
    end

    #############################################################################

    trait :with_irregular_income do
      student_finance { true }
      after(:create) do |application|
        create(:irregular_income, legal_aid_application: application)
      end
    end

    trait :submitted_to_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: %i[assessment_submitted generating_reports submitting_assessment].sample)
      end
    end

    trait :with_proceeding_types do
      transient do
        proceeding_types_count { 1 }
      end

      after(:create) do |application, evaluator|
        application.proceeding_types = create_list(:proceeding_type, evaluator.proceeding_types_count)
        application.application_proceeding_types.each do |apt|
          pt = apt.proceeding_type
          default_subst_sl = pt.default_substantive_scope_limitation || create(:scope_limitation, :substantive, joined_proceeding_type: pt)
          default_df_sl = pt.default_delegated_functions_scope_limitation || create(:scope_limitation, :delegated_functions, joined_proceeding_type: pt)
          apt.application_proceeding_types_scope_limitations << AssignedSubstantiveScopeLimitation.new(scope_limitation: default_subst_sl)
          apt.application_proceeding_types_scope_limitations << AssignedDfScopeLimitation.new(scope_limitation: default_df_sl)
          create(:chances_of_success, :with_optional_text, application_proceeding_type: apt)
        end
      end
    end

    trait :with_multiple_proceeding_types do
      after(:create) do |application, evaluator|
        if evaluator.proceeding_types.presence
          application.proceeding_types = evaluator.proceeding_types
        else
          application.proceeding_types << create(:proceeding_type, :with_real_data)
          application.proceeding_types << create(:proceeding_type, :as_occupation_order)
        end
        pt = application.lead_proceeding_type
        sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
        apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                                   scope_limitation_id: sl.id)
      end
    end

    trait :with_merits_submitted_at do
      merits_submitted_at { Time.current }
    end

    trait :with_substantive_scope_limitation do
      after(:create) do |application, evaluator|
        application.proceeding_types = evaluator.proceeding_types.presence || create_list(:proceeding_type, 1)
        pt = application.lead_proceeding_type
        sl = create :scope_limitation, :substantive_default, joined_proceeding_type: pt
        apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                                   scope_limitation_id: sl.id)
      end
    end

    trait :with_delegated_functions_scope_limitation do
      after(:create) do |application, evaluator|
        application.proceeding_types = evaluator.proceeding_types.presence || create_list(:proceeding_type, 1)
        pt = application.lead_proceeding_type
        sl = create :scope_limitation, :delegated_functions_default, joined_proceeding_type: pt
        apt = application.application_proceeding_types.find_by(proceeding_type_id: pt.id)
        AssignedDfScopeLimitation.create!(application_proceeding_type_id: apt.id,
                                          scope_limitation_id: sl.id)
      end
    end

    # usage:
    #
    #   create :legal_aid_application,
    #          :with_proceeding_type_and_scope_limtiations,
    #          this_proceeding_type: pt1,
    #          substantive_scope_limitation: sl1,
    #          df_scope_limitation: sl2
    #
    # The proceeding type pt1 and the scope limitations sl1 and sl2 must already exist.  This
    # trait will ensure that sl1 is the default substantive scope limitation for pt1, and sl2 is the default
    # delegated functions scope limitation, and add the proceeding type to the application.  Any existing
    # default scope limitations for the proceeding type will be deleted.
    #
    # sl2 may be nil, or the df_scope_limitation attribute omitted if no df scope limitaion is required.
    #
    trait :with_proceeding_type_and_scope_limitations do
      transient do
        this_proceeding_type { nil }
        substantive_scope_limitation { nil }
        df_scope_limitation { nil }
      end
      after(:create) do |application, evaluator|
        pt1 = evaluator.this_proceeding_type
        sl1 = evaluator.substantive_scope_limitation
        sl2 = evaluator.df_scope_limitation

        # destroy any eligible scope limitations and build from scratch
        ProceedingTypeScopeLimitation.where(proceeding_type_id: pt1.id).map(&:destroy!)
        pt1.proceeding_type_scope_limitations << create(:proceeding_type_scope_limitation, :substantive_default, scope_limitation: sl1)
        pt1.proceeding_type_scope_limitations << create(:proceeding_type_scope_limitation, :delegated_functions_default, scope_limitation: sl2) if sl2.present?
        application.proceeding_types << pt1
        apt = application.application_proceeding_types.first
        AssignedSubstantiveScopeLimitation.create!(application_proceeding_type: apt, scope_limitation: sl1)
        AssignedDfScopeLimitation.create!(application_proceeding_type: apt, scope_limitation: sl2) if sl2.present?
      end
    end

    trait :with_dependant do
      transient do
        dependants_count { 1 }
      end

      after(:create) do |application, evaluator|
        application.dependants = evaluator.dependants.presence || create_list(:dependant, 1)
        application.save
      end
    end

    trait :with_dwp_override do
      dwp_override { build :dwp_override }
      with_non_passported_state_machine
    end

    trait :with_own_home_mortgaged do
      own_home { 'mortgage' }
    end

    trait :with_own_home_owned_outright do
      own_home { 'owned_outright' }
    end

    trait :without_own_home do
      own_home { 'no' }
    end

    trait :with_home_sole_owner do
      shared_ownership { 'no_sole_owner' }
    end

    trait :with_student_finance do
      student_finance { true }
    end

    trait :with_home_shared_with_partner do
      shared_ownership { 'partner_or_ex_partner' }
    end

    trait :with_other_assets_declaration do
      other_assets_declaration { build :other_assets_declaration, :with_all_values }
    end

    trait :with_no_other_assets do
      other_assets_declaration { build :other_assets_declaration, :all_nil }
    end

    trait :with_policy_disregards do
      policy_disregards { build :policy_disregards }
    end

    trait :with_single_policy_disregard do
      policy_disregards { build :policy_disregards, :with_selected_value }
    end

    trait :with_populated_policy_disregards do
      policy_disregards { build :policy_disregards, :with_selected_values }
    end

    trait :with_savings_amount do
      savings_amount { build :savings_amount, :with_values }
    end

    trait :with_delegated_functions do
      transient do
        delegated_functions_date { nil }
      end
      used_delegated_functions_on { delegated_functions_date.presence || Time.zone.today }
      used_delegated_functions_reported_on { Time.zone.today }
      used_delegated_functions { true }
    end

    trait :with_substantive_application_deadline_on do
      substantive_application_deadline_on { SubstantiveApplicationDeadlineCalculator.call self }
    end

    trait :with_no_savings do
      savings_amount { build :savings_amount, :all_nil }
    end

    trait :with_no_other_assets do
      other_assets_declaration { build :other_assets_declaration, :all_nil }
    end

    trait :with_merits_statement_of_case do
      after(:create) do |application|
        create(:statement_of_case, legal_aid_application: application)
      end
    end

    trait :with_opponent do
      opponent { build :opponent }
    end

    trait :with_restrictions do
      has_restrictions { true }
      restrictions_details { Faker::Lorem.paragraph }
    end

    trait :with_open_banking_consent do
      provider_received_citizen_consent { true }
    end

    trait :with_consent do
      open_banking_consent { true }
    end

    trait :with_vehicle do
      transient do
        populate_vehicle { false }
      end
      own_vehicle { true }
      vehicle { populate_vehicle ? build(:vehicle, :populated) : build(:vehicle) }
    end

    trait :with_incident do
      latest_incident { build :incident }
    end

    trait :with_everything do
      with_applicant
      with_non_passported_state_machine
      applicant_entering_means
      with_savings_amount
      with_own_home_mortgaged
      property_value { rand(1...1_000_000.0).round(2) }
      outstanding_mortgage_amount { rand(1...1_000_000.0).round(2) }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { rand(1...99.0).round(2) }
      with_merits_statement_of_case
      with_opponent
      with_restrictions
      with_incident
      with_vehicle
      with_transaction_period
      with_other_assets_declaration
      with_policy_disregards
      with_savings_amount
      with_open_banking_consent
      with_consent
    end

    trait :with_everything_and_address do
      with_applicant_and_address
      with_non_passported_state_machine
      applicant_entering_means
      with_savings_amount
      with_own_home_mortgaged
      property_value { rand(1...1_000_000.0).round(2) }
      outstanding_mortgage_amount { rand(1...1_000_000.0).round(2) }
      shared_ownership { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.sample }
      percentage_home { rand(1...99.0).round(2) }
      with_merits_statement_of_case
      with_opponent
      with_restrictions
      with_incident
      with_vehicle
      with_transaction_period
      with_other_assets_declaration
      with_policy_disregards
      with_savings_amount
      with_open_banking_consent
      with_consent
    end

    trait :with_negative_benefit_check_result do
      benefit_check_result { build :benefit_check_result }
    end

    trait :with_positive_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :positive }
    end

    trait :with_application_proceeding_type do
      transient do
        proceeding_types_count { 1 }
      end

      after(:create) do |application, evaluator|
        application.proceeding_types = create_list(:proceeding_type, evaluator.proceeding_types_count)
        application.application_proceeding_types.each do |apt|
          create(:chances_of_success, :with_optional_text, application_proceeding_type: apt)
        end
      end
    end

    trait :passported do
      with_positive_benefit_check_result
    end

    trait :with_undetermined_benefit_check_result do
      benefit_check_result { build :benefit_check_result, :undetermined }
    end

    trait :non_passported do
      with_negative_benefit_check_result
    end

    trait :draft do
      draft { true }
    end

    trait :with_transaction_period do
      transaction_period_start_on { Date.current - 3.months }
      transaction_period_finish_on { Date.current }
    end

    trait :at_initiated do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :initiated)
      end

      provider_step { :applicants }
    end

    trait :at_entering_applicant_details do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :entering_applicant_details)
      end

      provider_step { :applicants }
    end

    trait :at_use_ccms do
      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :use_ccms, ccms_reason: :unknown)
      end

      provider_step { :use_ccms }
    end

    trait :at_checking_applicant_details do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_applicant_details)
      end

      provider_step { :check_provider_answers }
    end

    trait :at_checking_passported_answers do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_passported_answers)
      end

      provider_step { :check_passported_answers }
    end

    trait :at_applicant_details_checked do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :applicant_details_checked)
      end

      provider_step { :check_benefits }
    end

    trait :at_client_completed_means do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_citizen_answers)
      end

      provider_step { :client_completed_means }
    end

    trait :at_check_provider_answers do
      with_proceeding_types

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :provider_assessing_means)
      end

      provider_step { :check_provider_answers }
    end

    trait :at_checking_merits_answers do
      with_proceeding_types
      with_merits_statement_of_case

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :checking_merits_answers)
      end

      provider_step { :check_merits_answers }
    end

    trait :at_assessment_submitted do
      with_everything_and_address
      with_positive_benefit_check_result
      with_substantive_scope_limitation
      with_delegated_functions_scope_limitation
      with_delegated_functions
      with_cfe_v3_result
      with_means_report
      with_merits_report
      with_ccms_submission

      after(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :assessment_submitted)
      end

      provider_step { :end_of_application }
    end

    trait :at_submitting_assessment do
      with_everything_and_address
      with_positive_benefit_check_result
      with_substantive_scope_limitation
      with_delegated_functions_scope_limitation
      with_delegated_functions
      with_cfe_v3_result
      with_means_report
      with_merits_report
      with_ccms_submission

      before(:create) do |application|
        application.state_machine_proxy.update!(aasm_state: :submitting_assessment)
      end

      provider_step { :end_of_application }
    end

    trait :with_bank_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        create :bank_account_holder, bank_provider: bank_provider
        create :bank_error, applicant: application.applicant
        [90, 60, 30].each do |count|
          create :bank_transaction,
                 :benefits,
                 happened_at: count.days.ago,
                 bank_account: bank_account,
                 operation: 'credit',
                 meta_data: { code: 'CHB', label: 'child_benefit', name: 'Child Benefit' }
        end
      end
    end

    trait :with_benefits_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        [90, 60, 30].each do |count|
          create :bank_transaction,
                 :benefits,
                 happened_at: count.days.ago,
                 bank_account: bank_account,
                 operation: 'credit',
                 meta_data: { code: 'CHB', label: 'child_benefit', name: 'Child Benefit' }
        end
      end
    end

    trait :with_uncategorised_credit_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        [90, 60, 30].each do |count|
          create :bank_transaction, :uncategorised_credit_transaction, happened_at: count.days.ago, bank_account: bank_account, operation: 'credit'
        end
      end
    end

    trait :with_uncategorised_debit_transactions do
      after :create do |application|
        bank_provider = create :bank_provider, applicant: application.applicant
        bank_account = create :bank_account, bank_provider: bank_provider
        [90, 60, 30].each do |count|
          create :bank_transaction, :uncategorised_debit_transaction, happened_at: count.days.ago, bank_account: bank_account, operation: 'debit'
        end
      end
    end

    trait :with_cfe_v3_result do
      after :create do |application|
        cfe_submission = create :cfe_submission, legal_aid_application: application
        create :cfe_v3_result, submission: cfe_submission
      end
    end

    trait :with_means_report do
      with_cfe_v3_result
      after :create do |application|
        create :attachment, :means_report, legal_aid_application: application
      end
    end

    trait :with_bank_transaction_report do
      with_cfe_v3_result
      after :create do |application|
        create :attachment, :bank_transaction_report, legal_aid_application: application
      end
    end

    trait :with_merits_report do
      after :create do |application|
        create :attachment, :merits_report, legal_aid_application: application
      end
    end

    trait :with_ccms_submission do
      after :create do |application|
        create :ccms_submission, :case_created, legal_aid_application: application
      end
    end

    trait :with_ccms_submission_completed do
      after :create do |application|
        create :ccms_submission, :case_created, :case_completed, legal_aid_application: application
      end
    end

    trait :discarded do
      discarded_at { Time.current - 5.minutes }
    end
  end
end
