class CreateSpecializations < ActiveRecord::Migration[6.0]
  def change
    create_table :specializations do |t|
      t.string :name, null: false
      t.integer :organization_id, null: false

      t.timestamps
    end

    add_index :specializations, [:organization_id, :name], unique: true
  end
end
