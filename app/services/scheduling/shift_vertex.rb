class Scheduling::ShiftVertex
  include Scheduling

  def initialize(shift, prev_patterns = [], next_patterns = [])
    @shift = shift
    @prev = prev_patterns
    @next = next_patterns
  end

  def shift
    @shift
  end

  def prev
    @prev
  end

  def get_next
    @next
  end

  def add_next(new_next)
    if new_next.is_a? Array
      Rails.logger.debug "🦄 ADD NEXT is_a? Array true"
      @next += new_next
    elsif new_next.is_a? ShiftVertex
      Rails.logger.debug "🦄 ADD NEXT is_a? ShiftVertex true"
      @next.push(new_next)
    end
    #update_max_next_steps
  end

  def add_prev(new_prev)
    if new_prev.is_a? Array
      @prev += new_prev
    else
      @prev.push(new_prev)
    end
    update_max_prev_steps
  end

  def max_next_steps
    update_max_next_steps
    # p "🦋 MAX NEXT STEPS #{@shifty.id}: #{@max_next_steps}"
    @max_next_steps
  end

  def max_prev_steps
    if @max_prev_steps.nil?
      update_max_prev_steps
    end
    @max_prev_steps
  end

  def max_steps_between(node)
    return nil if node.nil?
    is_next = !get_next.map { |v| v.shift.id }.filter { |n| n == node.shift.id }.empty?
    is_prev = !is_next && !@prev.map { |v| v.shift.id }.filter { |n| n == node.shift.id }.empty?
    patterns = ShiftPatterns.new([])
    Rails.logger.debug "👻 max steps between #{node} is_prev: #{is_prev} & is_next: #{is_next}"
    if is_next
      patterns = ShiftPatterns.new(node.prev.intersection(get_next).map { |s| s.shift })
    elsif is_prev
      patterns = ShiftPatterns.new(prev.intersection(node.get_next).map { |s| s.shift })
    end
    max_length = patterns.max_length || 0
    return max_length
  end

  def max_path_length
    max_prev_steps + max_next_steps + 1
  end

  # We know that pattern can exist at this point…
  def random_path(params)
    Rails.logger.debug "💜 #{@shift.id} -> random path params #{params}"

    length = params[:length] || max_path_length
    contains = params[:contains] || []
    path = []

    if length > max_path_length
      Rails.logger.debug "🖤 LENGTH TOO LONG "
      return nil
    end

    path.push(self)

    next_params = { :length => length - path.length, :contains => contains }
    Rails.logger.debug "🦚 next_params #{next_params}"
    path += compute_random_path(next_params)

    length_match = path.length == length
    contains_all = contains.empty? || (contains.to_set.subset?(path.map { |s| s.shift.id }.to_set))
    unless length_match && contains_all
      Rails.logger.debug "⛔️ Get Random Path did not succeed with #{path.map { |s| s.shift.id }}; length match: #{length_match} (#{length}, contains all (#{contains}): #{contains_all}"
      return nil
    end

    path.map { |vertex| vertex.shift.id }.sort
  end


  # We know that pattern can exist at this point…
  def compute_random_path(params)
    path = []
    Rails.logger.debug "🦦 get_rnd_next #{params}"
    length = params[:length] || max_next_steps
    contains = params[:contains] || []

    return [] if length <= 0

    contained_vertices = @next.map(&:clone).filter { |p| contains.include? p.shift.id } + @prev.map(&:clone).filter { |p| contains.include? p.shift.id }

    # do not execute if no contains requirements are given
    unless contains.empty?
      path += contained_vertices
    end

    next_steps = @next.to_set.union(@prev.to_set).to_a

    path.each do |p|
      next_steps = next_steps.to_set.intersection(p.get_next.to_set.union(p.prev.to_set)).to_a
    end

    length.times do
      Rails.logger.debug "🥴 max_length times do"
      tmp_shift = SchedulingUtils.get_sample(next_steps, false)

      if tmp_shift.is_a? ShiftVertex
        path += [tmp_shift]
        next_steps = next_steps.to_set.intersection(tmp_shift.get_next.to_set.union(tmp_shift.prev.to_set)).to_a
      end

      break if path.length == length
    end

    Rails.logger.debug "🤢 got Random NEXT: #{path.map(&:to_s)}"
    path
  end

  # ====================================

  private def update_max_next_steps
    first = @next.min { |_, b| b.shift.start_time }
    @max_next_steps = first.nil? ? 0 : first.max_next_steps + 1
  end

  private def update_max_prev_steps
    last = @prev.max { |_, b| b.shift.end_time }
    @max_prev_steps = last.nil? ? 0 : last.max_prev_steps + 1
  end

  def to_s
    "========== @shift #{@shift.id} [max_path_length: #{max_path_length}]  [prev=> #{@prev.map { |prev| prev.shift.id }}, max_prev_count #{max_prev_steps}] [next=> #{@next.map { |prev| prev.shift.id }}, max_next_count #{max_next_steps}]"
  end

end
