class CreateWeeklyDemands < ActiveRecord::Migration[6.0]
  def change
    create_table :weekly_demands do |t|
      t.integer :week, null: false, default: 0
      t.integer :year, null: false, default: 2020

      t.string :demand, null: false

      t.timestamps
    end

    add_index :weekly_demands, [:week, :year], unique: true
  end
end
