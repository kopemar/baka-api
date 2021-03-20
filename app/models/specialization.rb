class Specialization < ApplicationRecord
  belongs_to :organization

  has_and_belongs_to_many :contracts
end
