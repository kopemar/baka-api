class ChangeColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :username, :string, null: false, unique: true, index: { :unique => true }
  end
end
