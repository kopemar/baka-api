class AddEndTimeToShifts < ActiveRecord::Migration[6.0]
  def change
    add_column :shifts, :end_time, :datetime
    add_column :shifts, :start_time, :datetime
  end
end
