class AddEmployeeIdToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :employee_id, :integer
  end
end
