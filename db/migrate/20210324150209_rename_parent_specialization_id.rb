class RenameParentSpecializationId < ActiveRecord::Migration[6.0]
  def change
    rename_column :shift_templates, :parent_specialization_id, :parent_template_id
  end
end
