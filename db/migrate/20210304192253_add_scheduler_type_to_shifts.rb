class AddSchedulerTypeToShifts < ActiveRecord::Migration[6.0]
  def change
    add_column :shifts, :scheduler_type, :integer, default: 0
  end
end
