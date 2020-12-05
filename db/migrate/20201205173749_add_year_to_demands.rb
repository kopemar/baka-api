class AddYearToDemands < ActiveRecord::Migration[6.0]
  def change
    add_column :demands, :year, :integer
  end
end
