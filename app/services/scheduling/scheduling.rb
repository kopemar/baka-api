module Scheduling

  class Scheduling
    class SchedulingError < StandardError; end

    def initialize(params)
      Rails.logger.debug "🦊 params: #{params}"
      period_id = params[:id]

      @priorities = get_priorities(params[:priorities]) || {
          :no_empty_shifts => 150,
          :demand_fulfill => 50
      }

      @scheduling_period = SchedulingPeriod.where(id: period_id).first
      raise SchedulingError.new("Invalid ID of scheduling period") if @scheduling_period.nil?
    end

    def call
      ActiveRecord::Base.transaction do
        days = @scheduling_period.scheduling_units
        return if days.empty?

        @to_schedule = ShiftTemplate::to_be_auto_scheduled.where(scheduling_unit_id: days.map(&:id))
        @shift_duration = @to_schedule.first.duration

        @employees = Employee::with_employment_contract
                         .where(organization_id: @scheduling_period.organization_id)

        Shift::in_scheduling_period(@scheduling_period.id).where(scheduler_type: SCHEDULER_TYPES[:SYSTEM]).delete_all

        schedule = get_first_solution(@employees)
        violations = get_soft_constraint_violations(schedule)

        Rails.logger.debug "📊 IMPROVE SOLUTION "
        schedule = try_to_improve_solution(schedule, violations)

        Rails.logger.debug "📅 SCHEDULE: #{schedule} "
        assign_shifts(schedule)
        return get_soft_constraint_violations(schedule)
      end
    end

    private def assign_shifts(schedule)
      Rails.logger.error schedule
      schedule.each do |employee_id, shift_ids|
        employee = @employees.find { |e| e.id == employee_id }
        templates = shift_ids.map { |id| @to_schedule.find { |template| template.id == id } }

        templates.each do |template|
          shift = Shift.from_template(template)
          shift.schedule_id = employee.contracts.active_employment_contracts.first.schedule_id
          shift.scheduler_type = SCHEDULER_TYPES[:SYSTEM]
          shift.save!
        end
      end
    end

    private

    def try_to_improve_solution(solution, violations)
      old_sanction = violations[:sanction]
      return solution if old_sanction == 0
      old_solution = Hash.new
      solution.map { |k, v| old_solution[k] = v.clone }

      Rails.logger.debug "============= OLD SOLUTION ==============="

      solution = try_to_improve(solution, violations, :no_empty_shifts) unless @priorities[:no_empty_shifts].nil? || @priorities[:no_empty_shifts] < 1

      Rails.logger.debug "🎁 OLD SOLUTION #{old_solution}"
      Rails.logger.debug "🎁 NEW SOLUTION #{solution}"
      solution = try_to_improve(solution, violations, :demand_fulfill) unless @priorities[:demand_fulfill].nil? || @priorities[:demand_fulfill] < 1
      solution
    end

    def try_to_improve(solution, violations, type)
      old_solution = Hash.new

      solution.map do |k, v|
        old_solution[k] = v.clone
      end

      old_sanction = violations[:sanction]
      solution.map { |k, v| old_solution[k] = v.clone }

      utilization = ScheduleStatistics.get_shifts_utilization(@to_schedule.map(&:id), solution)

      if type == :no_empty_shifts
        solution = Strategy::NoEmptyShiftsStrategy.new.try_to_improve(solution, violations[type][:violations], utilization, @patterns)
      elsif type == :demand_fulfill
        solution = Strategy::DemandFulfillStrategy.new.try_to_improve(solution, violations[type][:violations], @patterns, @employee_groups, @employees, @shift_duration)
      end

      new_sanction = get_soft_constraint_violations(solution)[:sanction]

      Rails.logger.debug "🧸 OLD SANCTION WAS #{old_sanction}; NEW SANCTION IS #{new_sanction} THEREFORE I AM PICKING #{old_sanction >= new_sanction ? "NEW" : "OLD"} solution in #{type}"

      old_sanction >= new_sanction ? solution : old_solution
    end

    #

    def get_soft_constraint_violations(solution)
      Rails.logger.debug "😘 get_soft_constraint_violations for #{solution}"
      violations = Hash.new
      violations[:no_empty_shifts] = NoEmptyShifts.get_violations_hash(@to_schedule, solution, @employees, @shift_duration, @priorities[:no_empty_shifts] || 0)  unless @priorities[:no_empty_shifts] == 0

      violations[:demand_fulfill] = DemandFulfill.get_violations_hash(@to_schedule, solution, @employee_groups, @shift_duration, @priorities[:demand_fulfill] || 0) unless @priorities[:demand_fulfill] == 0

      overall_sanction = violations.map { |_, violation| violation[:sanction] }.reduce(:+)
      violations[:sanction] = overall_sanction
      violations
    end

    def get_first_solution(employee_array)
      schedule = Hash.new

      @employee_groups =
          employee_array.group_by { |employee|
            employee.contracts.active_employment_contracts.first.work_load
          }

      @patterns = ShiftPatterns.new(@to_schedule)

      @employee_groups.each do |work_load, employees|
        shift_count = ScheduleStatistics.get_shift_count(work_load, @shift_duration, @patterns)
        Rails.logger.debug "========= shift_count #{shift_count} ==========="
        tmp_patterns = @patterns.patterns_of_params({length: shift_count, count: employees.length})
        # todo if already assigned
        employees.each { |employee|
          schedule[employee.id] = tmp_patterns.sample
        }
      end
      schedule
    end

    def get_employee_workload(employee)
      tmp_employee = employee
      if employee.is_a? Integer
        tmp_employee = @employees.find { |e| e.id == employee }
      end
      @employee_groups.select { |key|
        @employee_groups[key].select { |e| e == tmp_employee }.first.nil? == false
      }.keys.first
    end

    def get_priorities(priorities)
      return nil if priorities.nil?
      p = Hash.new
      priorities.to_enum.map { |k, v| p[k.to_sym] = v.to_i }
      Rails.logger.debug "✉️ get_priorities #{p}"
      p
    end
  end
end