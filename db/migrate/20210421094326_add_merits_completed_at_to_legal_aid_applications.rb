class AddMeritsCompletedAtToLegalAidApplications < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :merits_completed_at, :datetime
  end
end
