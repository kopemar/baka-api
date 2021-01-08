class CreateSchedulingPeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :scheduling_periods do |t|
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
