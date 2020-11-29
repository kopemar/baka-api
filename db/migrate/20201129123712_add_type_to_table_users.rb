class AddTypeToTableUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :type, :string, null: false, default: "User"
    add_column :users, :role, :integer, default: 0
  end
end
