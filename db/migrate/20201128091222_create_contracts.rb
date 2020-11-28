class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.integer :type
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
