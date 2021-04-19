class ShiftTimesCalcService < ApplicationService
  class ShiftServiceError < StandardError; end

  def initialize(params)
    @params = params
  end

  # result is deterministic, that's why IDs should be valid anytime & can be used in API...
  def call
    night_shift = @params[:night_shift] == true || @params[:night_shift] == true.to_s
    is_24_hours = @params[:is_24_hours] == true || @params[:is_24_hours] == true.to_s

    if night_shift && is_24_hours
      start_time = @params[:shift_start].to_time.beginning_of_minute
      end_time = 1.day.after(start_time)
    else
      start_time = @params[:start_time].to_time.beginning_of_minute
      end_time = @params[:end_time].to_time.beginning_of_minute
      end_time = 1.day.after(end_time) if night_shift
    end

    hours_in_day = (((end_time - start_time).to_d + 1) / 1.hour).round(2)

    Rails.logger.debug "🍯 start_time: #{start_time} | end_time: #{end_time}"

    hours = @params[:shift_hours].to_i
    minutes = @params[:break_minutes].to_i

    shift_duration = (hours + (minutes.to_f/60)).round(2)

    per_day = @params[:per_day].to_i

    array = Array.new

    raise ShiftServiceError.new("Select 24h mode instead") unless hours_in_day < 24 || is_24_hours
    raise ShiftServiceError.new("Working hours in the day can not be covered.") unless shift_duration*per_day >= hours_in_day
    raise ShiftServiceError.new("Too many shifts at one time") if shift_duration == hours_in_day && per_day > 1
    raise ShiftServiceError.new("Shift is too long.") unless shift_duration <= hours_in_day

    minutes_difference = ((hours_in_day - hours) * 60 - minutes) / (per_day - 1)
    (per_day - 1).times do |index|
      array.push(return_shift_hash_start((index*minutes_difference).minutes.after(start_time).to_time, hours, minutes, index + 1))
    end

    array.push(return_shift_hash_end(end_time, hours, minutes, per_day))
    array
  end

  def return_shift_hash_start(start_time, shift_hours, break_minutes, id)
    {:start_time => start_time.to_time.beginning_of_minute, end_time: shift_hours.hours.after(break_minutes.minutes.after(start_time).to_time.beginning_of_minute), :id => id}
  end

  def return_shift_hash_end(end_time, shift_hours, break_minutes, id)
    p end_time
    {:start_time => shift_hours.hours.before(break_minutes.minutes.before(end_time)).to_time.beginning_of_minute, :end_time => end_time.to_time.beginning_of_minute, :id => id}
  end
end