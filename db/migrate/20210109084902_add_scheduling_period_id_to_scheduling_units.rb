class AddSchedulingPeriodIdToSchedulingUnits < ActiveRecord::Migration[6.0]
  def change
    add_column :scheduling_units, :scheduling_period_id, :integer, null: false
  end
end
