class AddOrganizationIdToSchedulingPeriod < ActiveRecord::Migration[6.0]
  def change
    add_column :scheduling_periods, :organization_id, :integer, null: false
    add_column :scheduling_units, :organization_id, :integer, null: false
    add_column :shift_templates, :organization_id, :integer, null: false
  end
end
