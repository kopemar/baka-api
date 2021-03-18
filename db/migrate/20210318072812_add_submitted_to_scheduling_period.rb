class AddSubmittedToSchedulingPeriod < ActiveRecord::Migration[6.0]
  def change
    add_column :scheduling_periods, :submitted, :boolean, :null => false, :default => false
  end
end
