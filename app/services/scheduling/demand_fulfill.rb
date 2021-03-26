class Scheduling::DemandFulfill < Constraint
  include Scheduling

  def self.get_violations_hash(shifts, schedule, employee_groups, shift_duration, value_per_violation = 10)
    hash = Hash.new

    shift_priority_groups = Hash.new

    shifts.group_by(&:priority).map { |demand, shift| shift_priority_groups[demand] = shift.map(&:id) }
    Rails.logger.debug "🥸 schedule #{schedule}"
    total_assignments = schedule.map{ |_, v| v.length }.sum
    summary_demand = shifts.map(&:priority).sum
    average_demand =  (summary_demand / shifts.length).to_d
    assignments_per_average = (total_assignments / shifts.length).round

    average = get_assignments_per_demand(average_demand, assignments_per_average)

    # todo shift time rounding

    utilization = ScheduleStatistics.get_shifts_utilization(shifts.map(&:id), schedule)

    hash[:violations] = get_violating_shifts(utilization, average, shift_priority_groups)
    hash[:sanction] = get_sanction_from_array(hash[:violations], value_per_violation)
    Rails.logger.debug "🥳 DEMAND FULFILL VIOLATIONS #{hash}"
    hash
  end

  private

  def self.get_violating_shifts(utilization, average, priority_groups)
    violations = Hash.new
    priority_groups.each do |prio, shifts|
      employees_count = average[prio]

      shifts.each do |shift|
        Rails.logger.debug "UTILIZATION #{utilization}, SHIFT #{shift}"
        difference = utilization[shift] - (employees_count || 0)
        violations[shift] = difference if difference != 0
      end
    end

    violations
  end

  def self.get_sanction_from_array(hash, value_per_violation)
    value_per_violation * hash.map { |_, v| v.abs }.sum
  end

  def self.get_assignments_per_demand(average_demand, assignments_per_average)
    medium_demand_value = 3
    factor = 10.to_d
    demand = Hash.new

    medium_assignments = (assignments_per_average * (1 + ((medium_demand_value - average_demand) / factor).to_d)).round

    (1..5).each do |v|
      demand[v] = (medium_assignments * (1 - ((medium_demand_value - v) / factor).to_d)).round
    end

    demand
  end


end