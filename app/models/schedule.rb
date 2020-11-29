class Schedule < ApplicationRecord
  belongs_to :employee
  belongs_to :contract

  has_many :shifts
end
