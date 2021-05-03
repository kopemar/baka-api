module Scheduling
  module Strategy
    class FreeDaysInRowStrategy < Strategy
      def try_to_improve
        Rails.logger.debug "🐙 #{violations}"

        solution.each do |k, v|
          list = v.map { |s| templates.find { |t| t.id == s } }.filter { |s| !s.nil?}.sort_by { |s| s.start_time }
          free_hours = ScheduleHelpers.difference_between_shifts(period, list)
          max_two = free_hours.max(2)
          max_index = free_hours.index(max_two.max)
          Rails.logger.debug "🐢 #{free_hours} #{free_hours.index(max_two.min)}, #{list[max_index - 1].end_time unless list[max_index - 1].nil?} 🦀 TO #{list[max_index].start_time unless list[max_index].nil?}"

          min_index = free_hours.index(max_two.min)
          Rails.logger.debug "🐡 #{free_hours} #{min_index}, #{list[min_index - 1].end_time unless list[min_index - 1].nil?} 🦀 TO #{list[min_index].start_time unless list[min_index].nil?}"

          combination = []
          free = []
          list.combination(solution[k].length - 1).to_a.each do |a|
            free = ScheduleHelpers.difference_between_shifts(period, a.sort_by { |shift| shift.start_time })
            Rails.logger.debug "🐢 FREE WITHOUT ONE: #{free}"
            if free.max > TWO_DAYS_HOURS
              combination = a
              break
            end
          end
          Rails.logger.debug "🧅 Combination: #{combination.map(&:id)}"
          unless combination.empty?
            second = free.max(2).min
            min_index = free.index(second)
            Rails.logger.debug "🐳 SECOND (#{second}) of #{free} -> #{min_index}"
            f = nil
            f = combination[min_index - 1].id unless combination[min_index - 1].nil?
            l = nil
            l = combination[min_index].id unless combination[min_index].nil?
            patterns = @patterns.find_shifts_between(f, l)
            Rails.logger.debug "🍖 patterns: #{patterns}"
            old_solution = solution[k]
            solution[k] = (combination.map(&:id) + patterns).sort.uniq unless patterns.empty?
            Rails.logger.debug "🧇 SOLUTION FOR #{k} -> #{old_solution} TO #{solution[k]} (#{combination.map(&:id)} + #{patterns})"
          end
        end

        solution
      end
    end
  end
end

