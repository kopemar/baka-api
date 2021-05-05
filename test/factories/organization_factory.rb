class OrganizationFactory

  def self.generate_employees_1a(s1, s2, organization)
    @org = organization
    3.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    4.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    4.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    4.times do
      e = employee_active_contract(@org)
    end
  end

  def self.generate_employees_1b(s1, s2, s3, organization)
    @org = organization
    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s3)
      e.save!
    end
  end

  def self.generate_employees_1c(s1, s2, s3, s4, organization)
    @org = organization
    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.contracts.first.specializations.push(s3)
      e.contracts.first.specializations.push(s4)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s4)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s3)
      e.contracts.first.specializations.push(s4)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s4)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s3)
      e.save!
    end
  end

  def self.generate_employees_1d(s1, s2, s3, organization)
    @org = organization
    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    1.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s2)
      e.save!
    end

    4.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s1)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    2.times do
      e = employee_active_contract(@org)
      e.contracts.first.specializations.push(s3)
      e.save!
    end

    3.times do
      e = employee_active_contract(@org)
    end
  end
end
