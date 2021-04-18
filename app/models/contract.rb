class Contract < ApplicationRecord
  validates :schedule_id, uniqueness: true
  belongs_to :employee, optional: true
  after_create :create_schedule

  has_one :schedule
  has_and_belongs_to_many :specializations

  def type_to_id
    if self.type == "EmploymentContract"
      1
    elsif self.type == "AgreementToCompleteAJob"
      2
    elsif self.type == "AgreementToPerformAJob"
      3
    else
      0
    end
  end

  def create_schedule
    if self.schedule.nil?
      self.schedule_id = Schedule.create!(contract_id: self.id).id
      self.save!
    end
  end

  def active
    self.end_date.nil? || (end_date.after?(Date.today) && start_date.before?(Date.today))
  end

  def get_specializations
    Specialization.select('contracts.id').left_joins(:contracts).to_a
  end

  def hours_per_year(year = Date.now.year.to_i)
    Shift.where(schedule: Schedule.joins(:contract).where(contract_id: self.id))::planned_between("#{year}-01-01", "#{year}-12-31").sum('shifts.duration')
  end

  scope :active_employment_contracts, -> { where(type: "EmploymentContract")
                                               .where("end_date >= ? OR end_date IS NULL", Date::today)
                                               .where("start_date <= ?", Date::today)
  }

  scope :shifts_planned, -> (start_time, end_time) { joins(:schedule).merge(Schedule.planned_between(start_time, end_time)) }

  scope :active_agreements, -> { where(type: %w[AgreementToCompleteAJob AgreementToPerformAJob])
                                     .where("end_date >= ? OR end_date IS NULL", Date::today)
                                     .where("start_date <= ?", Date::today)
  }

  scope :with_no_shifts_planned_in, -> (start_time, end_time) { Contract.where.not(id: Contract.shifts_planned(start_time, end_time)) }

  def as_json(*args)
    hash = super(*args)
    hash.merge(active: self.active).merge( { first_name: self.employee.first_name, last_name: self.employee.last_name, }).merge!(type: type_to_id)
  end
end
