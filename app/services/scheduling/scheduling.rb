module Scheduling
  class BreakInnerLoop < StandardError; end
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

        Rails.logger.debug "📊 ============================ IMPROVE SOLUTION ============================="
        schedule = try_to_improve_solution(schedule, violations)

        Rails.logger.debug "📅 ========= SCHEDULE: #{schedule} =============="
        assign_shifts(schedule)
        return get_soft_constraint_violations(schedule)
      end
    end

    private def assign_shifts(schedule)
      Rails.logger.error schedule
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

      Rails.logger.debug "============= OLD SOLUTION ==============="

      solution = try_to_improve(solution, violations, :no_empty_shifts)

      Rails.logger.debug "🎁 OLD SOLUTION #{old_solution}"
      Rails.logger.debug "🎁 NEW SOLUTION #{solution}"
      try_to_improve(solution, violations, :demand_fulfill)
      solution
    end

    def try_to_improve(solution, violations, type)
      old_solution = Hash.new
      old_sanction = violations[:sanction]
      solution.map { |k, v| old_solution[k] = v.clone }

      utilization = ScheduleStatistics.get_shifts_utilization(@to_schedule.map(&:id), solution)

      if type == :no_empty_shifts
        improve_empty_shifts(solution, violations[type][:violations], utilization)
      elsif type == :demand_fulfill
        improve_demand_fulfill(solution, violations[type][:violations])
      end

      new_sanction = get_soft_constraint_violations(solution)[:sanction]

      Rails.logger.debug "🧸 OLD SANCTION WAS #{old_sanction}; NEW SANCTION IS #{new_sanction} THEREFORE I AM PICKING #{old_sanction >= new_sanction ? "NEW" : "OLD"} solution in #{type}"

      old_sanction >= new_sanction ? solution : old_solution
    end

    # Improves solution based on NoEmptyShifts constraint.
    # Finds random pattern where empty shift is present and assigns it to some employee.
    def improve_empty_shifts(solution, violations, utilization)
      exclude = utilization.filter { |_, v| v == 1 }.map { |k, _| k }.to_set
      Rails.logger.debug "🌡 exclude #{exclude}"

      # todo this won't be good enough
      employees = solution.filter { |_, v| !v.to_set.intersect?(exclude) }.map { |k, _| k }
      Rails.logger.debug "🌡 employees #{employees}"

      shifts_to_assign = violations.map { |k, _| k }

      Rails.logger.debug "🦠 shifts_to_assign #{shifts_to_assign} "

      if employees.length == 0
        assign_empty_shifts(solution, {:employees => @employees.map(&:id), :shifts => shifts_to_assign})
      else
        assign_empty_shifts(solution, {:employees => employees, :shifts => shifts_to_assign})
      end
    end

    def assign_empty_shifts(solution, params)
      employees = params[:employees]
      shifts = params[:shifts]

      remaining_shifts = shifts.map(&:clone).to_set
      division_factor = 1

      shifts.length.times do
        minimum = [remaining_shifts.length, 5].min
        combination_count = (minimum.to_d / division_factor).ceil

        found_any = analyze_combinations(remaining_shifts, combination_count, solution, employees)

        division_factor = found_any ? 1 : division_factor + 1
        Rails.logger.debug "🤥 Remaining: #{remaining_shifts}"

        break if remaining_shifts.empty?
      end
    end

    private def analyze_combinations(remaining_shifts, combination_count, solution, employees)
      remaining_shifts.to_a.reverse.combination(combination_count).to_a.each do |slice|
        # fixme smarter length, not just 5
        patterns = @patterns.patterns_of_params({:contains => slice, :length => 5})
        Rails.logger.debug "🤥 COMBINED #{patterns} (slice: #{slice})"
        unless patterns.first.nil?
          # todo not enough employees?
          solution[employees.pop] = patterns.first
          remaining_shifts = remaining_shifts.subtract(patterns.first.to_set)
          return true
        end
      end
      false
    end
    #
    def improve_demand_fulfill(solution, violations)
      Rails.logger.debug "😂 IMPROVE DEMAND FULFILL =================="
      employees = Hash.new
      violations_hash = Hash.new
      violations.group_by { |_, v| v }.map do |group, values|
        violations_hash[group] = values.map(&:first)
      end

      Rails.logger.debug "🤓 #{violations_hash}"

      solution.each do |employee, schedule|
        # fixme
        employees[employee] = schedule.map { |shift| (violations[shift] || 0) > 0 ? violations[shift] : 0 }.reduce(:+)
      end

      employees.each do |id|
        min_violations = violations_hash.keys.min
        Rails.logger.debug "🍄 EMPLOYEE #{id.first}"
        shift_count = get_shift_count(get_employee_workload(id.first))


        pattern = @patterns.patterns_of_params({length: shift_count, contains: violations_hash[min_violations].combination(shift_count).to_a.sample}).first
        Rails.logger.debug "🍄 CHANGING #{id.first} ========= #{solution[id.first]} TO #{pattern}"
        solution[id.first] = pattern unless pattern.nil?
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
        Rails.logger.debug "========= shift_count #{shift_count} ==========="
        tmp_patterns = @patterns.patterns_of_params({length: shift_count, count: employees.length})
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
        tmp_employee = @employees.find { |e| e.id == employee }
      end
      @employee_groups.select { |key|
        @employee_groups[key].select { |e| e == tmp_employee }.first.nil? == false
      }.keys.first
    end

  end
end