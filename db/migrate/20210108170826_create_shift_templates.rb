class CreateShiftTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :shift_templates do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :priority, default: 2, null: false
      t.integer :break_minutes, default: 0, null: false
      t.integer :duration, null: false
      t.timestamps
    end
  end
end
