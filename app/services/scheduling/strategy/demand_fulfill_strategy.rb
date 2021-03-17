module Scheduling
  module Strategy
    class DemandFulfillStrategy < Strategy
      def try_to_improve(solution, violations, patterns, employee_groups, all_employees, shift_duration)
        Rails.logger.debug "😂 IMPROVE DEMAND FULFILL"
        @employee_groups = employee_groups
        @employees = all_employees
        employees = Hash.new
        violations_hash = Hash.new
        violations_copy = Hash.new.deep_merge(violations)

        violations.group_by { |_, v| v }.map do |group, values|
          violations_hash[group] = values.map(&:first)
        end

        solution.each do |employee, schedule|
          # fixme
          employees[employee] = schedule.map { |shift| (violations[shift] || 0) > 0 ? violations[shift] : 0 }.reduce(:+)
        end

        Rails.logger.debug "🪖 #{employees}"

        employees.filter { |_, v| v > 0 }.each do |id|
          min_violations = violations_hash.keys.min
          break if min_violations == 0

          shift_count = ScheduleStatistics.get_shift_count(get_employee_workload(id.first), shift_duration, patterns)

          Rails.logger.debug "🍄 EMPLOYEE #{id.first} shift_count: #{shift_count}"
          Rails.logger.debug "🐶 #{violations_hash} / #{violations_copy}"

          pattern = patterns.patterns_of_params({length: shift_count, contains: violations_hash[min_violations].combination(shift_count).to_a.sample}).first
          unless pattern.nil?
            Rails.logger.debug "🍄 CHANGING #{id.first} ========= #{solution[id.first]} TO #{pattern}"
            modify_demand_hash(violations, violations_hash, solution[id.first], pattern)
            solution[id.first] = pattern
          end
        end
        solution
      end

      private def modify_demand_hash(violations, violations_hash, removed, added)
        modify_demand_hash_helper(violations, violations_hash, removed, -1)
        modify_demand_hash_helper(violations, violations_hash, added, 1)
      end

      private def modify_demand_hash_helper(violations, violations_hash, modified, f)
        modified.each do |m|
          Rails.logger.debug "😋 modify #{m}: #{f} / #{violations_hash}"
          violation_factor = violations[m] || 0
          violations_hash[violation_factor].delete(m) unless violations_hash[violation_factor].nil?
          violations_hash.delete(violation_factor) if !violations_hash[violation_factor].nil? && violations_hash[violation_factor].empty?

          violations[m] = (violation_factor += f)

          violations_hash[violation_factor] ||= []

          violations_hash[violation_factor].push(m)
        end
      end

      private def get_employee_workload(employee)
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
end
