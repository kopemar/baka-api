class AddWorkingDaysToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :working_days, :integer, array: true
  end
end
