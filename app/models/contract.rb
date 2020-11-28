class Contract < ApplicationRecord
  belongs_to :employee

  def active?
    self.end_date.before?(Date.today)
  end
end
