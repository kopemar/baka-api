class AddStartTimeToSchedulingUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :scheduling_units, :start_time, :datetime, null: false
    add_column :scheduling_units, :end_time, :datetime, null: false
  end
end
