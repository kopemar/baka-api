class ChangeColumnDateOfBirthInUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :birth_date, :date
    remove_column :users, :date_of_birth
  end
end
