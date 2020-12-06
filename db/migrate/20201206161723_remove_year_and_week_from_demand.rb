class RemoveYearAndWeekFromDemand < ActiveRecord::Migration[6.0]
  def change
    remove_column :demands, :year
    remove_column :demands, :week
  end
end
