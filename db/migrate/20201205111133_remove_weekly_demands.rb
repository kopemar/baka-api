class RemoveWeeklyDemands < ActiveRecord::Migration[6.0]
  def change
    drop_table :weekly_demands
  end


end
