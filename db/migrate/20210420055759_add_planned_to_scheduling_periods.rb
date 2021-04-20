class AddPlannedToSchedulingPeriods < ActiveRecord::Migration[6.0]
  def change
    add_column :scheduling_periods, :planned, :boolean, default: false
  end
end
