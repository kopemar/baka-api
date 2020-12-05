class AddWeekToDemands < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :week, :integer
  end
end
