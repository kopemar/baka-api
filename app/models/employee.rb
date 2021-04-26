class Employee < User
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birth_date, presence: true, allow_blank: false
  validate :validate_birth_date

  has_many :contracts

  attr_accessor :last

  def specializations
    Specialization.joins(:contracts).where(contracts: { employee_id: self.id })
  end

  def get_last_scheduled_shift_before(date)
    logger.debug "Last scheduled shift before: #{date} is #{self.last}"
    self.last ||= last_scheduled_shift_helper(date)
  end

  def has_agreement?
    self.contracts.active_agreements.length > 0
  end

  def is_underage?
    18.years.before(Date.today).before?(self.birth_date)
  end

  def active_employment_contract
    self.contracts.active_employment_contracts.first
  end

  # cannot plan the employees with contract starting in future...
  scope :with_employment_contract, -> {
    joins(:contracts).merge!(Contract.active_employment_contracts).select("DISTINCT ON (users.id) users.*")
  }

  def as_json(*args)
    hash = super(*args)
    hash.merge!(agreement: has_agreement?)
  end

  def can_work_at?(date)
    contracts.active_employment_contracts.each do |contract|
      return true if contract.working_days.include?(date.wday)
    end
    false
  end

  # validate whether age is > 15
  def validate_birth_date
    unless self.birth_date.to_date.before?(15.years.ago)
      errors.add(:birth_date, "not old enough")
    end
  end

  private def last_scheduled_shift_helper(date)
    shifts = Set.new
    contracts.active_employment_contracts.each do |contract|
      shift = contract.schedule.shifts.where('shifts.start_time < ?', date).max_by { |d| d.start_time }
      shifts.add(shift) unless shift.nil?
    end
    last = nil
    unless shifts.empty?
      last = shifts.max_by { |d| d.start_time }
    end
    self.last = last
  end
end
