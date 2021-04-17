class Employee < User
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birth_date, presence: true, allow_blank: false
  validate :validate_birth_date, :validate_username

  has_many :contracts

  attr_accessor :last

  def specializations
    Specialization.joins(:contracts).where(contracts: { employee_id: self.id })
  end

  def get_last_scheduled_shift_before(date)
    logger.debug "Last scheduled shift before: #{date} is #{self.last}"
    self.last ||= last_scheduled_shift_helper(date)
  end

  def get_possible_working_days(start_date, end_date)
    logger.debug "Possible_working_days #{start_date}, #{end_date}"
    working_days = Set.new
    start_date_wday = start_date.wday
    contracts.active_employment_contracts.each do |contract|
      contract_days = contract.working_days
      (end_date - start_date).to_i.times do |i|
        day = ((start_date_wday + i - 1) % 7) + 1
        result = contract_days.include?(day)
        if result
          working_days.add(i.days.after(start_date))
        end
      end
    end
    working_days
  end

  def has_agreement?
    self.contracts.active_agreements.length > 0
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

  def validate_username
    unless self.username.match?("[a-z0-9]+([a-z0-9.]+)+([a-z0-9]+)+", "[A-z0-9]+([A-z0-9.]).([A-z0-9]+)+")
      errors.add(:username, "username does not match pattern")
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
