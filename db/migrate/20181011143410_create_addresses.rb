class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :address_line_one, null: false
      t.string :address_line_two
      t.string :city
      t.string :county
      t.string :postcode, null: false
      t.references :applicant, foreign_key: true, null: false
      t.timestamps null: false
    end
  end
end
