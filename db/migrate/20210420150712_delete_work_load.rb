class DeleteWorkLoad < ActiveRecord::Migration[6.0]
  def change
    change_column :contracts, :work_load, :float,  null: true
  end
end
