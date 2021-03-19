class DeleteEmployees < ActiveRecord::Migration[6.0]
  def change
    drop_table :assigned_employees
  end
end
