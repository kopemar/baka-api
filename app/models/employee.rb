class Employee < User
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birth_date, presence: true, allow_blank: false

  has_many :contracts

  # def as_json(options={})
  #   super(include: :contracts)
  # end

  scope :with_employment_contract, -> { joins(:contracts).merge!(Contract.active_employment_contracts) }
end
