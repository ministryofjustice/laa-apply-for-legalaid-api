FactoryBot.define do
  factory :application_proceeding_type do
    proceeding_type
    legal_aid_application

    trait :with_chances_of_success do
      after(:create) do |application_proceeding_type|
        create :chances_of_success, application_proceeding_type: application_proceeding_type
      end
    end
  end
end
