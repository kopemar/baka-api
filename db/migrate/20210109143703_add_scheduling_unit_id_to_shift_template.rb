class AddSchedulingUnitIdToShiftTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :shift_templates, :scheduling_unit_id, :integer
  end
end
