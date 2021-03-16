class ShiftTemplateGenerator < ApplicationService
  class TemplateGeneratorError < StandardError; end

  def initialize(params)
    @params = params
  end

  def call
    scheduling_period_id = @params[:id].to_i
    working_days = @params[:working_days].to_a.map{ |d| d.to_i }

    excluded = @params[:excluded].nil? ? Hash.new : @params[:excluded]

    excluded.to_enum.to_h.map {|k, v|
      excluded[k] = v.map(&:to_i)
    }

    Rails.logger.debug "😻 excluded #{excluded}"

    period = SchedulingPeriod.where(id: scheduling_period_id).first

    Rails.logger.debug "🙀 Scheduling PERIOD: #{period.start_date}"

    units = period.generate_scheduling_units_in(working_days)
    template_times = ShiftTimesCalcService.call(@params)
    templates = Array.new

    working_days.each do |day|
      unit = units.select{ |u| u.start_time.to_date == (day - 1).days.after(period.start_date) }.first
      template_times.each { |time|
        templates.push(unit.create_shift_template(time[:start_time], time[:end_time], @params[:break_minutes].to_i)) if excluded[day.to_s].nil? || !excluded[day.to_s].include?(time[:id].to_i) }
    end
    templates
  end
end