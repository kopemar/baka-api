class CreateFcmTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :fcm_tokens do |t|
      t.integer :user_id
      t.string :fcm_token
      t.string :client, unique: true
      t.string :string

      t.timestamps
    end
  end
end
