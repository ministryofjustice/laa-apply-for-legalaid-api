FactoryBot.define do
  factory :application_proceeding_type do
    proceeding_type
    legal_aid_application

    trait :with_chances_of_success do
      after(:create) do |application_proceeding_type|
        create :chances_of_success, application_proceeding_type: application_proceeding_type
      end
    end

    trait :with_proceeding_type_scope_limitation do
      after(:create) do |application_proceeding_type|
        apt = application_proceeding_type
        pt = apt.proceeding_type
        default_subst_sl = pt.default_substantive_scope_limitation || create(:scope_limitation, :substantive, joined_proceeding_type: pt)
        default_df_sl = pt.default_delegated_functions_scope_limitation || create(:scope_limitation, :delegated_functions, joined_proceeding_type: pt)
        apt.application_proceeding_types_scope_limitations << AssignedSubstantiveScopeLimitation.new(scope_limitation: default_subst_sl)
        apt.application_proceeding_types_scope_limitations << AssignedDfScopeLimitation.new(scope_limitation: default_df_sl)
      end
    end
  end
end
