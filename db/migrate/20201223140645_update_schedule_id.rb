class UpdateScheduleId < ActiveRecord::Migration[6.0]
  def change
    change_column :shifts, :schedule_id, :integer, null: true
  end
end
