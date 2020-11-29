class AddActiveToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :active, :boolean
  end
end
