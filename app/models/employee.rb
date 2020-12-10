class Employee < User
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birth_date, presence: true, allow_blank: false

  has_many :contracts

  attr_accessor :last

  def get_last_scheduled_day_before(date)
    if self.last.nil?
      days = Set.new
      contracts.active_employment_contracts.each do |contract|
        shift = contract.schedule.shifts.where('shifts.start_time < ?', date).max_by { |d| d.start_time }
        days.add(shift) unless shift.nil?
      end
      unless days.empty?
        self.last = days.max_by { |d| d.start_time }
      end
    end
    self.last
  end

  def get_possible_working_days(start_date, end_date)
    @working_days = Set.new
    start_date_wday = start_date.wday
    contracts.active_employment_contracts.each do |contract|
      contract_days = contract.working_days
      (end_date - start_date).to_i.times do |i|
        day = ((start_date_wday + i - 1) % 7) + 1
        result = contract_days.include?(day)
        if result
          @working_days.add(i.days.after(start_date))
        end
      end
    end
  end

  def has_multiple_active_contracts?
    self.contracts.active_employment_contracts.length > 1
  end

  scope :with_employment_contract, -> { joins(:contracts).merge!(Contract.active_employment_contracts).select("DISTINCT ON (users.id) users.*") }

  scope :to_be_planned, -> (start_date, end_date)  { Employee.with_employment_contract.joins(:contracts).merge!(Contract.with_no_shifts_planned_in(start_date, end_date)).select("DISTINCT ON (users.id) users.*") }

  def as_json(*args)
    hash = super(*args)
    # hash.merge!(contracts: self.contracts)
  end

  def can_work_at?(date)
    contracts.active_employment_contracts.each do |contract|
      return true if contract.working_days.include?(date.wday)
    end
    false
  end

  def can_work_at(date, start_date, end_date)
    if @working_days == nil || @working_days.empty?
      get_possible_working_days(start_date, end_date)
    end
    @working_days.include?(date)
  end

end
