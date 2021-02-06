class ShiftTimesCalcService < ApplicationService
  class ShiftServiceError < StandardError; end

  def initialize(params)
    @params = params
  end

  def call
    if @params[:start_time].nil? || @params[:end_time].nil? || @params[:shift_hours].nil? || @params[:break_minutes].nil?
      raise ShiftServiceError.new("Some of the required params is missing.")
    end

    start_time = @params[:start_time].to_time.beginning_of_minute
    end_time = @params[:end_time].to_time.beginning_of_minute

    hours_in_day = (((end_time - start_time).to_d + 1) / 1.hour).round(2)

    hours = @params[:shift_hours].to_i
    minutes = @params[:break_minutes].to_i

    shift_duration = (hours + (minutes.to_f/60)).round(2)

    per_day = @params[:per_day].to_i

    night_shift = @params[:night_shift].nil? ? false : @params[:night_shift]

    array = Array.new

    p "========= shift duration: #{hours_in_day}"
    raise ShiftServiceError.new("Working hours in the day can not be covered.") unless shift_duration*per_day >= hours_in_day
    raise ShiftServiceError.new("Shift is too long.") unless shift_duration <= hours_in_day

    minutes_difference = ((hours_in_day - hours) * 60 - minutes) / (per_day - 1)
    (per_day - 1).times do |index|
      p "index: #{((hours_in_day - hours)) * 60 - minutes}"
      array.push(return_shift_hash_start((index*minutes_difference).minutes.after(start_time).to_time, hours, minutes))
    end

    array.push(return_shift_hash_end(end_time, hours, minutes))
    array
  end

  def return_shift_hash_start(start_time, shift_hours, break_minutes)
    {:start_time => start_time.to_time.beginning_of_minute, end_time: shift_hours.hours.after(break_minutes.minutes.after(start_time).to_time.beginning_of_minute) }
  end

  def return_shift_hash_end(end_time, shift_hours, break_minutes)
    p end_time
    {:start_time => shift_hours.hours.before(break_minutes.minutes.before(end_time)).to_time.beginning_of_minute, :end_time => end_time.to_time.beginning_of_minute}
  end
end