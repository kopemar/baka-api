class CreateEmploymentContracts < ActiveRecord::Migration[6.0]
  def change
    remove_column :contracts, :type
    add_column :contracts, :type, :string, null: false, default: "Contract"

    add_column :contracts, :work_load, :float

    add_column :contracts, :maximum_working_hours, :integer
  end
end
