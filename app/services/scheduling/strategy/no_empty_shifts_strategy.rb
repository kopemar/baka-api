module Scheduling
  module Strategy
    class NoEmptyShiftsStrategy < Strategy
      def initialize(params)
        super(params)
      end

      def try_to_improve
        Rails.logger.info "📦 Improve empty shifts"

        # vyberu vsechny prazdny smeny
        shifts_to_assign = violations.map { |k, _| k }

        # rozradim prazdny smeny mezi zamestnance
        assign_empty_shifts(solution, {:assigned_employees => employees, :shifts => shifts_to_assign})
        solution
      end

      private def assign_empty_shifts(solution, params)
        employees = params[:assigned_employees]
        shifts = params[:shifts]

        shifts.each do |shift|
          @recent_employees = []
          unless manage_swap shift, false
            manage_swap shift, true
          end
        end
      end

      private def manage_swap(shift, exclude)
        success = false
        3.times do
          employee = solution.keys.filter { |e| exclude || !@recent_employees.include?(e) }.sample
          swap = analyze_combinations(shift, solution, employee)
          if !swap.empty? && (!exclude || is_second_better?(solution[employee], swap))
            solution[employee] = swap
            update_queue employee
            success = true
            break
          end
        end
        success
      end

      private def is_second_better?(first, second)
        first.map { |f| utilization[f] }.count { |_, v| v == 0 } > second.map { |f| utilization[f] }.count { |_, v| v == 0 }
      end

      private def update_queue(element)
        @recent_employees.push element
        @recent_employees.unshift if @recent_employees.length > 3
      end

      private def analyze_combinations(shift, solution, employee)
        Rails.logger.debug "🐱 employee groups: #{employee}"

        specializations = employee_groups.filter { |_, v| v.map(&:id).include? employee }.keys.first[:specializations]

        template = templates.find { |s| s.id == shift }
        swap = []
        makes_sense = template.specialization_id.nil? || specializations.include?(template.specialization_id)
        Rails.logger.debug "🥇 makes_sense: #{makes_sense}"
        if makes_sense
          swap = @patterns.try_to_swap(solution[employee], shift)
          Rails.logger.debug "🍍 try_to_swap for #{employee} and add #{shift} result: #{swap}"
        end
        swap
      end

    end
  end
end