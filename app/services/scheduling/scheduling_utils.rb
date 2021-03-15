class Scheduling::SchedulingUtils
  class << self
    def get_sample(array, can_be_empty)
      Rails.logger.debug "😵 get_sample from #{array.map { |vert| vert.shift.id }}"
      if can_be_empty
        array.push([])
      end

      sample = array.sample

      Rails.logger.debug "🤮 sample #{sample} is_a ShiftVertex: #{sample.is_a?(Scheduling::ShiftVertex)} "
      sample.is_a?(Scheduling::ShiftVertex) ? sample : nil
    end

    def max_next_steps_with(nodes)
      return 0 if nodes.empty? || nodes.length == 1
      nodes = nodes.sort { |node| node.shift.start_time }
      max_steps = nodes.last.max_next_steps
      nodes.each_with_index do |_, index|
        if index + 1 < nodes.length
          Rails.logger.debug "👿 MAX_STEPS #{max_steps} INDEX #{index} #{nodes.map(&:to_s)}"
          x = nodes[index].max_steps_between(nodes[index + 1])
          Rails.logger.debug "🤡 #{x.to_s}"
          max_steps += x
        end
      end
      max_steps
    end
  end
end