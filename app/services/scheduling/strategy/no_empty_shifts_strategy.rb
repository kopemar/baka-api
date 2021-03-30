module Scheduling
  module Strategy
    class NoEmptyShiftsStrategy < Strategy
      def initialize(params)
        super(params)
      end

      def try_to_improve
        Rails.logger.info "📦 Improve empty shifts"
        # Nema smysl to menit u tech, ktery maji presne jednoho zamestnance
        exclude = utilization.filter { |_, v| v == 1 }.map { |k, _| k }.to_set

        # vyberu nekteryho ze zamestnancu, kterej ma smysl dle predchoziho (tedy nema ani jednu smenu, na ktery je sam)
        employees = solution.filter { |_, v| !v.to_set.intersect?(exclude) }.map { |k, _| k }

        # pokud nemam zadnyho takovyho zamestnance, tak vezmu vsechny a nahodnyho z nich
        employees = solution.map { |k, _| k } if employees.empty?

        # vyberu vsechny prazdny smeny
        shifts_to_assign = violations.map { |k, _| k }

        # rozradim prazdny smeny mezi zamestnance
        assign_empty_shifts(solution, {:assigned_employees => employees, :shifts => shifts_to_assign})
        solution
      end

      private def assign_empty_shifts(solution, params)
        employees = params[:assigned_employees]
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
          employee = employees.last # -> vzit delku podle toho posledniho

          length = 5
          length = solution[employee].length unless employee.nil?
          slice = slice.sample(length) if slice.length > length
          patterns = @patterns.patterns_of_params({:contains => slice, :length => length})
          Rails.logger.debug "🤥 COMBINED #{patterns} (slice: #{slice})"

          unless patterns.first.nil? || employees.empty?
            # todo not enough employees?
            solution[employees.pop] = patterns.first
            remaining_shifts = remaining_shifts.subtract(patterns.first.to_set)
            return true
          end
        end
        false
      end

    end
  end
end