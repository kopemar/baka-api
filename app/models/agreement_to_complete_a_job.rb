class AgreementToCompleteAJob < Contract
  before_save :add_maximum_working_hours

  def add_maximum_working_hours
    self.maximum_working_hours = 300
  end

end