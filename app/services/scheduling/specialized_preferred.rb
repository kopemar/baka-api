class Scheduling::SpecializedPreferred < Constraint
  include Scheduling

  def self.get_violation_hash(shifts, schedule, value_per_violation = 10)
    shifts_by_specialization = group_shifts_by_specialization(shifts)
    if shifts_by_specialization.keys.length < 2 || shifts_by_specialization[nil].nil?
      return {:sanction => 0, :violations => {}}
    end

    Rails.logger.debug "🎃 shifts_by specialization #{shifts_by_specialization}"

    violation_shifts = ScheduleStatistics.get_shifts_utilization(shifts.filter { |s| s.priority > 0 }, schedule).filter { |shift|
      found = shifts.find { |s| s.id == shift }
      (found.sub_templates.empty? unless found.nil?) && shifts_by_specialization[nil].include?(shift)
    }

    violations_count = violation_shifts.sum { |_, v| v }
    Rails.logger.debug "🎃 violation #{violation_shifts}"

    {:sanction => violations_count * value_per_violation, :violations => violation_shifts}
  end

  private

  def self.group_shifts_by_specialization(shifts)
    shifts_by_specialization = Hash.new
    shifts.group_by(&:specialization_id).map do |k, v|
      shifts_by_specialization[k] = v.map(&:id)
    end
    return shifts_by_specialization
  end
end
