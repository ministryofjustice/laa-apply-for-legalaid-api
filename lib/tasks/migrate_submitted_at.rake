namespace :migrate_submitted_at do
  desc 'Migrate ChancesOfSuccess#submitted_at to LegalAidApplication#merits_submitted_at'
  task migrate: :environment do
    raise StandardError, 'Column merits_submitted_at does not exist' unless ActiveRecord::Base.connection.column_exists?(:legal_aid_applications, :merits_submitted_at)

    chances_of_successes = ProceedingMeritsTask::ChancesOfSuccess.where.not(submitted_at: nil)

    chances_of_successes.each do |cs|
      laa = cs.legal_aid_application
      laa.merits_submitted_at = cs.submitted_at

      laa.save!
    end
  end
end
