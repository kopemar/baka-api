class Schedule < ApplicationRecord
  # belongs_to :contract

  has_many :shifts

  def as_json(*args)
    hash = super(*args)
    hash.merge!(shifts: self.shifts)
  end
end
