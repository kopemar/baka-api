class CreateSchedulingUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduling_units do |t|

      t.timestamps
    end
  end
end
