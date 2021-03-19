class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :assigned_employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :birth_name
      t.date :date_of_birth

      t.timestamps
    end
  end
end
