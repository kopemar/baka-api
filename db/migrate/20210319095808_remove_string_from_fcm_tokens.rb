class RemoveStringFromFcmTokens < ActiveRecord::Migration[6.0]
  def change
    remove_column :fcm_tokens, :string
    remove_column :users, :fcm_token
  end
end
