class SchedulingService < ApplicationService
  class SchedulingError < StandardError; end

  def initialize(params)
    @params = params

    period_id = params["id"]

    raise SchedulingError.new("No ID of scheduling period") if period_id.nil?
    @scheduling_period = SchedulingPeriod.where(id: period_id).first
    raise SchedulingError.new("Invalid ID of scheduling period") if @scheduling_period.nil?
  end

  def call
    ActiveRecord::Base.transaction do
      days = @scheduling_period.scheduling_units
      return if days.empty?

      @to_schedule = ShiftTemplate::to_be_auto_scheduled.where(scheduling_unit_id: days.map(&:id))

      @shift_duration = @to_schedule.first.duration

      p "Shifts in period #{Shift::in_scheduling_period(@scheduling_period.id).to_a}"

      @employees = Employee::with_employment_contract
                       .where(organization_id: @scheduling_period.organization_id)

      Shift.where(scheduler_type: SCHEDULER_TYPES[:SYSTEM]).joins(:schedule).where(schedule_id: Schedule.select(:id).joins(:contract).where(contract_id: Contract.select(:id).joins(:employee).where(employee_id: @employees.map(&:id)))).delete_all

      schedule = get_first_solution(@employees)

      assign_shifts(schedule)
    end
  end

  private def assign_shifts(schedule)
    schedule.each do |employee_id, shift_ids|
      employee = @employees.select { |e| e.id == employee_id }.first
      templates = shift_ids.map { |id| @to_schedule.select { |template| template.id == id }.first }

      templates.each do |template|
        shift = Shift.from_template(template)
        shift.schedule_id = employee.contracts.active_employment_contracts.first.schedule_id
        shift.scheduler_type = SCHEDULER_TYPES[:SYSTEM]
        shift.save!
      end
    end
  end

  private def get_first_solution(employee_array)
    schedule = Hash.new

    employee_groups =
        employee_array.group_by { |employee|
          employee.contracts.active_employment_contracts.first.work_load
        }

    @patterns = ShiftPatterns.new(@to_schedule)

    employee_groups.each do |work_load, employees|
      shift_count = [((work_load * WEEKLY_WORKING_HOURS).to_d / @shift_duration).ceil, @scheduling_period.scheduling_units.count].min
      tmp_patterns = @patterns.patterns_of_length(shift_count)

      # todo if already assigned
      employees.each { |employee|
        schedule[employee.id] = tmp_patterns.sample
      }
    end
    schedule
  end

end