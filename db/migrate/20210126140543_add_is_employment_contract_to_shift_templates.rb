class AddIsEmploymentContractToShiftTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :shift_templates, :is_employment_contract, :boolean
  end
end
