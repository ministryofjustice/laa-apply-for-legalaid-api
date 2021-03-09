class AddUniqueIdexToApplicationProceedingTypesScopeLimitations < ActiveRecord::Migration[6.1]
  def up
    remove_index :application_proceeding_types_scope_limitations, name: :index_application_proceeding_scope_limitation
    add_index :application_proceeding_types_scope_limitations,
              [:application_proceeding_type_id, :scope_limitation_id],
              name: :index_application_proceeding_scope_limitation,
              unique: true
  end

  def down
    remove_index :application_proceeding_types_scope_limitations, name: :index_application_proceeding_scope_limitation
    add_index :application_proceeding_types_scope_limitations,
              [:application_proceeding_type_id, :scope_limitation_id],
              name: :index_application_proceeding_scope_limitation
  end
end
