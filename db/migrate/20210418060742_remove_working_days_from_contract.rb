class RemoveWorkingDaysFromContract < ActiveRecord::Migration[6.0]
  def change
    remove_column :contracts, :work_load
  end
end
