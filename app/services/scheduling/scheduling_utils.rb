class Scheduling::SchedulingUtils
  class << self
    def get_sample(array, can_be_empty)
      Rails.logger.debug "😵 [SchedulingUtils] get_sample from #{array.map { |vert| vert.shift.id }}"
      if can_be_empty
        array.push([])
      end

      sample = array.sample

      Rails.logger.debug "🤮 [SchedulingUtils] sample #{sample} is_a ShiftVertex: #{sample.is_a?(Scheduling::ShiftVertex)} "
      sample.is_a?(Scheduling::ShiftVertex) ? sample : nil
    end

    def max_steps_with(nodes)
      nodes = nodes.sort_by { |node| node.shift.start_time.to_i }
      Rails.logger.debug "🤡 #{nodes.map(&:to_s)}"
      max_steps = 0
      nodes.each_with_index do |_, index|
        if index + 1 < nodes.length
          Rails.logger.debug "👿  [SchedulingUtils] MAX_STEPS_WITH #{nodes.map(&:to_s)}"
          x = nodes[index].max_steps_between(nodes[index + 1])
          Rails.logger.debug "🤡 [SchedulingUtils::max_steps increment by] #{x.to_s}"
          max_steps += x
        end
      end

      steps = max_steps + nodes.first.max_prev_steps + nodes.last.max_next_steps + nodes.length
      Rails.logger.debug "🤡 FIRST #{nodes.first} \n LAST #{nodes.last}"

      Rails.logger.debug "🤡 [SchedulingUtils::max_steps_final] max_steps = #{max_steps} + max_prev_steps = #{nodes.first.max_prev_steps} + max_next_steps = #{nodes.last.max_next_steps} nodes_length = + #{nodes.length} ===> #{steps}"
      return steps
    end
  end
end