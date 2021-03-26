class Specialization < ApplicationRecord
  include Filterable

  belongs_to :organization

  has_and_belongs_to_many :contracts
  has_many :shift_templates

  scope :for_organization, -> (organization_id) {
    joins(:organization).where(organizations: { id: organization_id })
  }

  scope :filter_by_for_template, -> (template_id) {
    specialized_shifts = ShiftTemplate.joins(:specialization).where('shift_templates.parent_template_id = ?', template_id)

    Specialization.left_joins(:shift_templates).where.not(shift_templates: specialized_shifts).distinct
  }

end
