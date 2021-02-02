class ShiftTimesCalcService < ApplicationService
  def initialize(params)
    @params = params
  end

  def call
    start_time = @params[:start_time].to_time
    end_time = @params[:end_time].to_time

    hours_in_day = ((end_time - start_time).to_d + 1) / 1.hour

    hours = @params[:shift_hours]
    minutes = @params[:break_minutes]

    per_day = @params[:per_day]

    night_shift = @params[:night_shift]

    array = Array.new
    array.push(return_shift_hash_start(start_time, hours, minutes))
    array.push(return_shift_hash_end(end_time, hours, minutes))
    array
  end

  def return_shift_hash_start(start_time, shift_hours, break_minutes)
    Hash.new(start_time: start_time, end_time: shift_hours.hours.after(break_minutes.minutes.after(start_time)))
  end

  def return_shift_hash_end(end_time, shift_hours, break_minutes)
    Hash.new(start_time: shift_hours.hours.before(break_minutes.minutes.before(start_time)), end_time: end_time)
  end
end