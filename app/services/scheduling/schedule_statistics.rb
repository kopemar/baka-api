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
end