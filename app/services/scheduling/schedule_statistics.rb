class Scheduling::ScheduleStatistics
  include Scheduling
  def self.get_shifts_utilization(shifts, schedule)
    array = []
    schedule.map { |_, value| array += value unless value.nil? }

    hash = Hash.new

    shifts.map { |shift| hash[shift] = 0}
    array.uniq.map { |a| hash[a] = array.count(a) }

    return hash
  end

  def self.get_shift_employees(shifts, schedule)
    Rails.logger.debug "🏵 #{shifts}"
    hash = Hash.new
    shifts.each do |shift|

      hash[shift.id] = []
    end
    schedule.each do |employee, value|
      (value || []).each do |shift|
        hash[shift].push employee
      end
    end
    return hash
  end

  def self.get_shift_count(work_load, shift_duration, patterns)
    Rails.logger.debug "⛈ #{patterns.max_length}"
    [((work_load * WEEKLY_WORKING_HOURS).to_d / shift_duration).ceil, patterns.max_length].min
  end

end