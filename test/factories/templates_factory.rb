class TemplatesFactory

  def self.generate_templates_1a(templates, s1, s2, org)
    templates.each_with_index do |t, index|
      if TestDataA.demand_1.include? index
        t.update(priority: 1)
      elsif TestDataA.demand_2.include? index
        t.update(priority: 2)
      elsif TestDataA.demand_3.include? index
        t.update(priority: 3)
      elsif TestDataA.demand_4.include? index
        t.update(priority: 4)
      end

      if TestDataA.specialization_s1.include? index
        priority = 2
        if TestDataA.specialization_s1_demand_1.include? index
          priority = 1
        end
        create_specialized_template(t, s1, priority, org)
      end
      if TestDataA.specialization_s2.include? index
        priority = 2
        if TestDataA.specialization_s2_demand_1.include? index
          priority = 1
        elsif TestDataA.specialization_s2_demand_3.include? index
          priority = 3
        end
        create_specialized_template(t, s2, priority, org)
      end
    end
  end

  def self.generate_templates_1b(templates, s1, s2, s3, org)
    templates.each_with_index do |t, index|
      #t.update(priority: 0)

      if TestDataB.specialization_s1.include? index
        priority = 3
        if TestDataB.specialization_s1_demand_2.include? index
          priority = 2
        end
        create_specialized_template(t, s1, priority, org)
      end
      if TestDataB.specialization_s2.include? index
        priority = 3
        create_specialized_template(t, s2, priority, org)
      end

      if TestDataB.specialization_s3.include? index
        priority = 2
        create_specialized_template(t, s3, priority, org)
      end
    end
  end




  def self.create_specialized_template(parent_template, specialization, priority, org)
    ShiftTemplate.create!(
        start_time: parent_template.start_time,
        end_time: parent_template.end_time,
        break_minutes: parent_template.break_minutes,
        priority: priority,
        organization_id: org.id,
        is_employment_contract: parent_template.is_employment_contract,
        parent_template_id: parent_template.id,
        specialization_id: specialization.id
    )
  end

end
