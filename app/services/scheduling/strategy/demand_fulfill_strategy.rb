module Scheduling
  module Strategy
    class DemandFulfillStrategy < Strategy
      def initialize(params)
        super(params)
      end

      def try_to_improve
        Rails.logger.debug "😂 IMPROVE DEMAND FULFILL"
        valid_employees = Hash.new
        violations_hash = Hash.new
        violations_copy = Hash.new.deep_merge(violations)

        violations.group_by { |_, v| v }.map do |group, values|
          violations_hash[group] = values.map(&:first)
        end

        solution.each do |employee, schedule|
          # fixme
          valid_employees[employee] = schedule.map { |shift| (violations[shift] || 0) > 0 ? violations[shift] : 0 }.reduce(:+)
        end

        Rails.logger.debug "🪖 #{valid_employees}"

        valid_employees.each do |employee, _|
          specializations = employee_groups.filter { |_, v| v.map(&:id).include? employee }.keys.first[:specializations]

          min_violations = violations_hash.keys.min
          break if min_violations >= 0

          shift_count = solution[employee].length
          combination_count = shift_count

          Rails.logger.debug "🍄 EMPLOYEE #{employee} shift_count: #{shift_count}"
          Rails.logger.debug "🐶 #{violations_hash} / #{violations_copy}"

          pattern = nil
          i = 0
          while pattern.nil? && combination_count > 0
            i += 1
            i_divided = (i / 8.to_d).floor
            combination_count = shift_count - i_divided
            sample = get_shifts_sample(violations_hash, combination_count)
            pattern = patterns.patterns_of_params({length: shift_count, contains: sample, specializations: specializations }).first
            unless pattern.nil?
              Rails.logger.debug "🍄 CHANGING #{employee} ========= #{solution[employee]} TO #{pattern}"
              modify_demand_hash(violations, violations_hash, solution[employee], pattern)
              solution[employee] = pattern
            end
          end
        end
        solution
      end

      private def get_shifts_sample(violations_hash, length)
        shifts = []

        violations_hash.each do |k, v|
          shifts += v if k < 0
        end

        shifts.sample(length)
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
          tmp_employee = employees.find { |e| e.id == employee }
        end
        employee_groups.select { |key|
          employee_groups[key].select { |e| e == tmp_employee }.first.nil? == false
        }.keys.first[:work_load]
      end

    end
  end
end
