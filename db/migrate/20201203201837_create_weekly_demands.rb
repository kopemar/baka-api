class CreateWeeklyDemands < ActiveRecord::Migration[6.0]
  def change
    create_table :weekly_demands do |t|
      t.integer :week
      t.integer :year

      t.string :demand

      t.timestamps
    end
  end
end
