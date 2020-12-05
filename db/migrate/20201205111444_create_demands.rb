class CreateDemands < ActiveRecord::Migration[6.0]
  def change
    create_table :demands do |t|
      t.integer :specialization, null: false, default: 0
      t.integer :demand, null: false , default: 3
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end
    add_index :demands, [:start_time, :end_time, :specialization], unique: true
  end
end
