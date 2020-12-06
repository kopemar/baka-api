class AddEndDateToDemands < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :end_date, :date
  end
end
