module Scheduling
  module Strategy
    class FreeDaysInRowStrategy < Strategy
      def try_to_improve
        Rails.logger.debug "🐙 #{violations}"

        solution.each do |k, v|
          list = v.map { |s| templates.find(s) }.sort_by { |s| s.start_time }
          free_hours = ScheduleHelpers.difference_between_shifts(period, list)
          max_two = free_hours.max(2)
          max_index = free_hours.index(max_two.max)
          Rails.logger.debug "🐢 #{free_hours} #{free_hours.index(max_two.min)}, #{list[max_index - 1].end_time unless list[max_index - 1].nil?} 🦀 TO #{list[max_index].start_time unless list[max_index].nil?}"

          min_index = free_hours.index(max_two.min)
          Rails.logger.debug "🐡 #{free_hours} #{min_index}, #{list[min_index - 1].end_time unless list[min_index - 1].nil?} 🦀 TO #{list[min_index].start_time unless list[min_index].nil?}"

          combination = []
          list.combination(4).to_a.each do |a|
            free = ScheduleHelpers.difference_between_shifts(period, a)
            Rails.logger.debug "🐢 #{free}"
            if free.max > TWO_DAYS_HOURS
              combination = a
              break
            end
          end
        end

        solution
      end
    end
  end
end

