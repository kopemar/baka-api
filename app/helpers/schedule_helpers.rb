class ScheduleHelpers
  def self.shift_difference_hours(first, other)
    (other.start_time - first.end_time).to_d / 1.hour
  end

  def self.start_difference_hours(period, other)
    Rails.logger.debug "🦄 PERIOD: #{period.start_date.midnight.to_time} OTHER: #{other.start_time}"
    (other.start_time - period.start_date.midnight.to_time).to_d / 1.hour
  end

  def self.end_difference_hours(period, other)
    Rails.logger.debug "🦄 PERIOD: #{period.end_date.end_of_day.to_time} OTHER: #{other.end_time}"
    (period.end_date.end_of_day.to_time - other.end_time).to_d / 1.hour
  end

  def self.difference_between_shifts(period, shifts)
    Rails.logger.debug "🦄 DIFFERENCE BETWEEN SHIFTS: #{shifts}"
    shifts = shifts.sort_by { |s| s.start_time }
    free_hours = []
    shifts.each_with_index do |_, i|
      if i == 0
        free_hours += [ScheduleHelpers.start_difference_hours(period, shifts[i])]
      end
      if shifts[i + 1].nil?
        free_hours += [ScheduleHelpers.end_difference_hours(period, shifts[i])]
      else
        free_hours += [ScheduleHelpers.shift_difference_hours(shifts[i], shifts[i + 1])]
      end
    end
    return free_hours
  end
end