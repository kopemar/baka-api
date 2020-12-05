class CreateWeeks < ActiveRecord::Migration[6.0]
  def change
    create_table :weeks do |t|
      t.integer :year
      t.integer :week

      t.timestamps
    end
  end
end
