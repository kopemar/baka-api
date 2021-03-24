# DPP 

class AgreementToCompleteAJob < Contract
  before_save :add_maximum_working_hours

  def add_maximum_working_hours
    self.maximum_working_hours = 300
  end
  
  def hours_per_year(year = Date.now.year.to_i)
    Shift.where(schedule: Schedule.joins(:contract).where(contract_id: self.id))::planned_between("#{year}-01-01", "#{year}-12-31").sum('shifts.duration')
  end

end