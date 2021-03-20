class CreateContractsSpecializations < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts_specializations do |t|
      t.integer :contract_id
      t.integer :specialization_id
    end
  end
end
