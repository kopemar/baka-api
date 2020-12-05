class Employee < User
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birth_date, presence: true, allow_blank: false

  has_many :contracts

  def has_multiple_active_contracts?
    self.contracts.active_employment_contracts.length > 1
  end

  scope :with_employment_contract, -> { joins(:contracts).merge!(Contract.active_employment_contracts).select("DISTINCT ON (users.id) users.*") }

  def as_json(*args)
    hash = super(*args)
    hash.merge!(multiple_contracts: self.has_multiple_active_contracts?)
  end

end
