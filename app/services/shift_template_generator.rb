class ShiftTemplateGenerator < ApplicationService
  class TemplateGeneratorError < StandardError; end

  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      scheduling_period_id = @params[:id].to_i
      working_days = @params[:working_days].to_a.map { |d| d.to_i }

      excluded = @params[:excluded].nil? ? Hash.new : @params[:excluded]

      excluded.to_enum.to_h.map { |k, v|
        excluded[k] = v.map(&:to_i)
      }

      Rails.logger.debug "😻 excluded #{excluded}"

      period = SchedulingPeriod.find(scheduling_period_id)

      ShiftTemplate::in_scheduling_period(period.id).where(is_employment_contract: true).delete_all

      period.generate_scheduling_units_in(working_days)

      template_times = ShiftTimesCalcService.call(@params)
      templates = Array.new
      units = period.scheduling_units.to_a
      working_days.each do |day|
        unit = units.find { |u| u.start_time.to_date == (day - 1).days.after(period.start_date) }
        template_times.each { |time|
          end_time = time[:end_time].to_datetime
          Rails.logger.debug "🙀 Shift template: #{time} #{end_time.to_datetime.before?(time[:start_time].to_datetime)}"
          # hotfix to make 24-hours working day work
          if end_time.to_time.before?(time[:start_time].to_time) && @params[:is_24_hours] == true
            Rails.logger.debug "🌚🌚"
            end_time = 1.day.after(end_time)
          end
          templates.push(unit.create_shift_template(time[:start_time].to_datetime, end_time, @params[:break_minutes].to_i)) if excluded[day.to_s].nil? || !excluded[day.to_s].include?(time[:id].to_i) }
      end
      return templates
    end
  end
end