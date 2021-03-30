class Scheduling::NoEmptyShifts < Constraint
  include Scheduling

  def self.is_violated(shifts, schedule)
    NoEmptyShifts.get_sanction(shifts, schedule, 100) > 0
  end

  def self.get_empty_shifts(shifts, schedule)
    p "============ DEBUG SCHEDULE #{schedule} =================="
    hash = ScheduleStatistics.get_shifts_utilization(shifts, schedule)
    p hash
    return hash.filter do |_, value|
      value == 0
    end
  end

  def self.get_sanction(shifts, schedule, value_per_violation)
    p "get_empty_shifts: #{get_empty_shifts(shifts, schedule)}"
    value_per_violation * get_empty_shifts(shifts, schedule).length
  end

  def self.get_violations_hash(shifts, schedule, value_per_violation = 10)
    hash = Hash.new

    hash[:violations] = get_empty_shifts(shifts.filter { |it| it.priority > 0 }.map(&:id), schedule)
    hash[:sanction] = get_sanction_from_array(hash[:violations], value_per_violation)
    hash
  end

  private

  def self.get_sanction_from_array(empty_shifts, value_per_violation)
    puts "empty_shifts: #{empty_shifts.length}"
    value_per_violation * empty_shifts.length
  end

end
