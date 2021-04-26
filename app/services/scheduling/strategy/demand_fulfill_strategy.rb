module Scheduling
  module Strategy
    class DemandFulfillStrategy < Strategy
      def initialize(params)
        super(params)
      end

      def try_to_improve
        Rails.logger.debug "🏆 try_to_improve #{templates}"
        shift_employees = ScheduleStatistics.get_shift_employees(templates, solution)
        violations_hash = violations.clone
        Rails.logger.debug "🎖 #{violations_hash}"

        violations_hash.keys.filter { |k| violations_hash[k] > 0}.each do |x|
          violations_hash[x].times do
            swap = []
            employee = shift_employees[x].sample
            possible = violations_hash.keys.filter { |k| violations_hash[k] < 0 }.sample(3)
            swap = @patterns.try_to_swap_element(solution[employee], x, possible) unless possible.nil?
            if swap.empty?
              employee = shift_employees[x].sample
              possible = violations_hash.keys.filter { |k| violations_hash[k] < 0 }.sample(3) unless possible.nil?
              swap = @patterns.try_to_swap_element(solution[employee], x, possible)
            else
              violations[x] -= 1
              swap.intersection(possible).each do |s|
                violations[s] += 1
              end
              solution[employee] = swap
            end

            Rails.logger.debug "🥁 swap with #{x} / #{possible}: #{swap}"
          end
        end

        return solution
      end

      private def update_queue(element)
        @recent_employees.push element
        @recent_employees.unshift if @recent_employees.length > 3
      end

    end
  end
end
