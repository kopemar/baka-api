module Scheduling
  module Strategy
    class DemandFulfillStrategy < Strategy
      def initialize(params)
        super(params)
      end

      def try_to_improve
        Rails.logger.debug "🏆 try_to_improve #{templates.to_a}"
        shift_employees = ScheduleStatistics.get_shift_employees(templates, solution)
        violations_hash = violations.clone
        Rails.logger.debug "🎖 #{violations_hash}"

        violations_hash.keys.filter { |k| violations_hash[k] > 0 }.each do |x|
          violations_hash[x].times do
            try_to_swap(shift_employees, x, violations_hash)
          end
        end

        return solution
      end

      private
      def update_queue(element)
        @recent_employees.push element
        @recent_employees.unshift if @recent_employees.length > 3
      end

      def try_to_swap(shift_employees, x, violations_hash)
        3.times do
          swap = []
          employee = shift_employees[x].sample
          specializations = employee_groups.filter { |_, v| v.map(&:id).include? employee }.keys.first[:specializations]
          possible_helper = violations_hash.keys.filter { |template| violations_hash[template] < 0 && (templates.find(template).specialization_id.nil? || specializations.include?(templates.find(template).specialization_id)) }
          possible = possible_helper.sample([3, possible_helper.length].min)
          swap = @patterns.try_to_swap_element(solution[employee], x, possible) unless possible.nil?
          Rails.logger.debug "🥁 swap with specializations: #{specializations} old: #{x} / #{possible}: #{violations_hash} #{swap}"
          unless swap.empty?
            violations_hash[x] -= 1
            swap.intersection(possible).each do |s|
              Rails.logger.debug "SWAP #{violations_hash[x]} #{violations_hash[s]}"
              violations_hash[s] += 1
            end
            solution[employee] = swap
            break
          end
        end
      end

    end
  end
end
