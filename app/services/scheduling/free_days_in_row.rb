class Scheduling::FreeDaysInRow < Constraint
  include Scheduling

  def self.get_violations_hash(shifts, solution, period, value_per_violation = 10)
    shift_list = {}
    solution.each do |k, v|
      list = v.map { |s| shifts.find(s) }
      free_hours = ScheduleHelpers.difference_between_shifts(period, list)
      shift_list[k] = free_hours.max
    end
    Rails.logger.debug "🦋 🦋 🦋 #{shift_list}"

    violations = shift_list.filter { |_, br| br < 48 }

    {sanction: violations.keys.length * value_per_violation, violations: violations}
  end

  # todo might be utils fun...

end
