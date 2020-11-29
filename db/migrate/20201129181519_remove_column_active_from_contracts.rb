class RemoveColumnActiveFromContracts < ActiveRecord::Migration[6.0]
  def change
    remove_column :contracts, :active, :string
  end
end
