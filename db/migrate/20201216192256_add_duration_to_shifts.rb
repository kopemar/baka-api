class AddDurationToShifts < ActiveRecord::Migration[6.0]
  def change
    add_column :shifts, :duration, :integer, default: 8
  end
end
