class ChangeOrganizationIdInUser < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :organization_id, :integer, default: 1
  end
end
