class Scheduling::ScheduleStatistics
  include Scheduling
  def self.get_shifts_utilization(shifts, schedule)
    array = []
    schedule.map { |_, value| array += value unless value.nil? }
    p array
    hash = Hash.new
    p "======== UTILIZATION"
    shifts.map do |i|
      p "======== UTILIZATION"
      p i

      hash[i] = 0
    end
    array.uniq.map { |a| hash[a] = array.count(a) }

    return hash
  end
end