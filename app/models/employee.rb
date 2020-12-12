class Employee < User
  validates :first_name, presence: true, allow_blank: false
  validates :last_name, presence: true, allow_blank: false
  validates :birth_date, presence: true, allow_blank: false

  has_many :contracts

  attr_accessor :last

  def get_last_scheduled_shift_before(date)
    self.last ||= last_scheduled_shift_helper(date)
  end

  def get_possible_working_days(start_date, end_date)
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

  def active_contracts_count
    self.contracts.active_employment_contracts.length
  end

  # cannot plan the employees with contract starting in future...
  scope :with_employment_contract, -> {
    joins(:contracts).merge!(Contract.active_employment_contracts).select("DISTINCT ON (users.id) users.*")
  }

  scope :to_be_planned, -> (start_date, end_date) {
    Employee.with_employment_contract.joins(:contracts).merge!(Contract.with_no_shifts_planned_in(start_date, end_date)).select("DISTINCT ON (users.id) users.*")
  }

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
    @working_days ||= get_possible_working_days(start_date, end_date)
    @working_days.include?(date)
  end

  def get_schedule_for_shift_time(start_time, end_time)
    day_of_week = start_time.wday
    unless can_work_at(start_time, start_time.midnight, end_time.end_of_day)
      logger.debug "Contracts for: #{username}: #{contracts.all.to_json}"

      if active_contracts_count == 1
        logger.debug "XXXXX #{contracts.first.schedule.id}"
        schedule = contracts.first.schedule
        return schedule if schedule.shifts.planned_between(MINIMUM_BREAK_HOURS.hours.before(start_time), MINIMUM_BREAK_HOURS.hours.after(end_time)).empty?
      else
        contracts.active_employment_contracts.each do |c|
          schedule = c.schedule
          if schedule.contract.working_days.include?(day_of_week)
            logger.debug "For #{username}, #{start_time} to #{end_time}"
            logger.debug "For #{username}: #{schedule.shifts.map(&:start_time)} to #{schedule.shifts.map(&:end_time)}, empty: #{schedule.shifts.planned_between(MINIMUM_BREAK_HOURS.hours.before(start_time), MINIMUM_BREAK_HOURS.hours.after(end_time)).empty?}"
            logger.debug schedule.shifts.planned_between(MINIMUM_BREAK_HOURS.hours.before(start_time), MINIMUM_BREAK_HOURS.hours.after(end_time))
            unless schedule.shifts.planned_between(MINIMUM_BREAK_HOURS.hours.before(start_time), MINIMUM_BREAK_HOURS.hours.after(end_time)).empty?
              logger.debug "Nothing planned between #{MINIMUM_BREAK_HOURS.hours.before(start_time)} and #{MINIMUM_BREAK_HOURS.hours.after(end_time)} for #{username}"
              logger.debug "XXXXX #{schedule}"
              return schedule
            end
          end
        end
      end
    end
    nil
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
