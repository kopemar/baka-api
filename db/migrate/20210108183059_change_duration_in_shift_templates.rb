class ChangeDurationInShiftTemplates < ActiveRecord::Migration[6.0]
  def change
    change_column :shift_templates, :duration, :float, :default => 0.0
  end
end
