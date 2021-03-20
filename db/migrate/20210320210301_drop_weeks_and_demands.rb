class DropWeeksAndDemands < ActiveRecord::Migration[6.0]
  def change
    drop_table :demands
    drop_table :weeks
  end
end
