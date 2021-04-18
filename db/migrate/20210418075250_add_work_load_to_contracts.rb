class AddWorkLoadToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :work_load, :float, default: 1.0, null: false
    remove_column :contracts, :working_days
  end
end
