class AddSpecializationIdToShiftTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :shift_templates, :specialization_id, :integer, null: true
    add_column :shift_templates, :parent_specialization_id, :integer, null: true
  end
end
