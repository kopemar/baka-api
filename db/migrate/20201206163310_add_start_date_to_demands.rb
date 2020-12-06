class AddStartDateToDemands < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :start_date, :date
  end
end
