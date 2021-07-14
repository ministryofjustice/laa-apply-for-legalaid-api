class AddNoCashIncomeAndOutgoings < ActiveRecord::Migration[6.1]
  def change
    add_column :legal_aid_applications, :no_cash_income, :boolean
    add_column :legal_aid_applications, :no_cash_outgoings, :boolean
  end
end
