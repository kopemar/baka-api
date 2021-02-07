class AddExcludedToShiftTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :shift_templates, :excluded, :boolean
  end
end
