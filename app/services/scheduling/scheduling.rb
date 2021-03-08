module Scheduling
  class Scheduling
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

        @employees = Employee::with_employment_contract
                         .where(organization_id: @scheduling_period.organization_id)

        Shift.where(scheduler_type: SCHEDULER_TYPES[:SYSTEM]).joins(:schedule).where(schedule_id: Schedule.select(:id).joins(:contract).where(contract_id: Contract.select(:id).joins(:employee).where(employee_id: @employees.map(&:id)))).delete_all

        schedule = get_first_solution(@employees)
        violations = get_soft_constraint_violations(schedule)

        p "============================ IMPROVE SOLUTION ============================="
        schedule = try_to_improve_solution(schedule, violations)

        p "========= SCHEDULE: #{schedule} =============="
        assign_shifts(schedule)
        return get_soft_constraint_violations(schedule)
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

    private

    def try_to_improve_solution(solution, violations)
      old_sanction = violations[:sanction]
      old_solution = Hash.new
      solution.map { |k, v| old_solution[k] = v.clone }

      p "============= OLD SOLUTION ==============="
      p old_solution
      p solution
      solution = try_to_improve(solution, violations, :no_empty_shifts)

      solution = try_to_improve(solution, violations, :demand_fulfill)
      p "OLD SANCTION = #{old_sanction}"

      p "OLD SOLUTION #{old_solution}"
      p "NEW SOLUTION #{solution}"

      solution
    end

    def try_to_improve(solution, violations, type)
      old_solution = Hash.new
      old_sanction = violations[:sanction]
      solution.map { |k, v| old_solution[k] = v.clone }

      if type == :no_empty_shifts
        improve_empty_shifts(solution, violations[type][:violations])
      elsif type == :demand_fulfill
        improve_demand_fulfill(solution, violations[type][:violations])
      end

      new_sanction = get_soft_constraint_violations(solution)[:sanction]
      old_sanction >= new_sanction ? solution : old_solution
    end

    # Improves solution based on NoEmptyShifts constraint.
    # Finds random pattern where empty shift is present and assigns it to some employee.
    def improve_empty_shifts(solution, violations)
      violations.each_with_index do |violation, i|
        employee = @employees[i]
        work_load = @employee_groups.select { |key|
          @employee_groups[key].select { |e| e == employee }.first.nil? == false
        }.keys.first

        shift_count = get_shift_count(work_load)

        solution[employee.id] = @patterns.patterns_of_params({ length: shift_count, contains: [violation.first] }).sample
      end
    end

    #
    def improve_demand_fulfill(solution, violations)
      p "================== IMPROVE DEMAND FULFILL =================="
      employee_badness = Hash.new
      violations_hash = Hash.new
      violations.group_by { |_, v| v }.map do |group, values|
        violations_hash[group] = values.map(&:first)
      end

      solution.each do |employee, schedule|
        employee_badness[employee] = schedule.map { |shift| (violations[shift] || 0 ) > 0 ? violations[shift] : 0 }.reduce(:+)
      end

      employee_badness = employee_badness.filter { |_, v| v > 0 }

      employee_badness.each do |id, _|
        min_violations = violations_hash.keys.min
        pattern = @patterns.patterns_of_params( { length: get_shift_count(get_employee_workload(id)), contains: violations_hash[min_violations] } ).first
        p "CHANGING ========= #{solution[id]} TO #{pattern}"

        solution[id] = pattern unless pattern.nil?
      end

      solution
    end

    def get_soft_constraint_violations(solution)
      violations = Hash.new
      violations[:no_empty_shifts] = NoEmptyShifts.get_violations_hash(@to_schedule, solution, @employees, @shift_duration, 100)

      violations[:demand_fulfill] = DemandFulfill.get_violations_hash(@to_schedule, solution, @employee_groups, @shift_duration, 100)

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
        shift_count = get_shift_count(work_load)
        p "========= shift_count #{shift_count} ==========="
        tmp_patterns = @patterns.patterns_of_params({ length: shift_count, count: employees.length })
        # todo if already assigned
        employees.each { |employee|
          schedule[employee.id] = tmp_patterns.sample
        }
      end
      schedule
    end

    def get_shift_count(work_load)
      [((work_load * WEEKLY_WORKING_HOURS).to_d / @shift_duration).ceil, @patterns.max_length].min
    end

    def get_employee_workload(employee)
      tmp_employee = employee
      if employee.is_a? Integer
        tmp_employee = @employees.find { |e| e.id == employee}
      end
      @employee_groups.select { |key|
        @employee_groups[key].select { |e| e == tmp_employee }.first.nil? == false
      }.keys.first
    end

  end
end