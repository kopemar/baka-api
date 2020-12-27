class AddUserScheduledToShifts < ActiveRecord::Migration[6.0]
  def change
    add_column :shifts, :user_scheduled, :boolean, default: false
  end
end
