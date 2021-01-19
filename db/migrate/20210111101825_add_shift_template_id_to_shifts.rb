class AddShiftTemplateIdToShifts < ActiveRecord::Migration[6.0]
  def change
    add_column :shifts, :shift_template_id, :integer
    add_column :shifts, :break_minutes, :integer
    change_column :shifts, :duration, :float
  end
end
