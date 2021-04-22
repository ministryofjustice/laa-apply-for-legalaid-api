namespace :migrate_chances_of_success_association do
  desc 'Replace LegalAidApplication association with ApplicationProceedingType for ChancesOfSuccess'
  task migrate: :environment do
    raise StandardError, 'Column does not exist' if ActiveRecord::Base.connection.column_exists?(:chances_of_successes, :application_proceeding_type_id)

    chances_of_successes = ProceedingMeritsTask::ChancesOfSuccess.where.not(legal_aid_application_id: nil)

    chances_of_successes.each do |chances_of_success|
      laa = chances_of_success.legal_aid_application
      application_proceeding_type_id = laa&.lead_application_proceeding_type&.id

      chances_of_success.application_proceeding_type_id = application_proceeding_type_id
      chances_of_success.save!
    end
  end
end
