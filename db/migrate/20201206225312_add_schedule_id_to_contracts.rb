class AddScheduleIdToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :shifts, :schedule_id, :integer
    add_column :contracts, :schedule_id, :integer
    add_column :schedules, :contract_id, :integer
  end
end
