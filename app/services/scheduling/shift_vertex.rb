class Scheduling::ShiftVertex
  include Scheduling

  attr_reader :prev, :nexts, :shift
  attr_accessor :specialized

  def initialize(shift, specialized = [], prev_patterns = [], next_patterns = [])
    @shift = shift
    @prev = prev_patterns
    @nexts = next_patterns
    @specialized = specialized || []
  end

  def add_next(new_next)
    if new_next.is_a? Array
      @nexts += new_next
    elsif new_next.is_a? ShiftVertex
      @nexts.push(new_next)
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
    is_next = !nexts.map { |v| v.shift.id }.filter { |n| n == node.shift.id }.empty?
    is_prev = !is_next && !@prev.map { |v| v.shift.id }.filter { |n| n == node.shift.id }.empty?
    patterns = ShiftPatterns.new([])
    if is_next
      patterns = ShiftPatterns.new(node.prev.intersection(nexts).map { |s| s.shift })
    elsif is_prev
      patterns = ShiftPatterns.new(prev.intersection(node.nexts).map { |s| s.shift })
    end
    max_length = patterns.max_length || 0
    Rails.logger.debug "👻 max steps between #{node} and #{self.to_s} is_prev: #{is_prev} & is_next: #{is_next}: steps between #{max_length}"
    max_length
  end

  def max_path_length
    max_prev_steps + max_next_steps + 1
  end

  # We know that pattern can exist at this point…
  def random_path(params)
    Rails.logger.debug "💜 [ShiftVertex::random_path] #{@shift.id} -> random path params #{params}"

    length = params[:length] || max_path_length
    contains = params[:contains] || []
    specializations = params[:specializations]
    path = []

    if length > max_path_length
      Rails.logger.debug "🖤 [ShiftVertex::random_path] LENGTH TOO LONG "
      return nil
    end

    next_params = { :length => length - path.length, :contains => contains }
    Rails.logger.debug "🦚 next_params #{next_params}"
    path += compute_random_path(next_params)

    length_match = path.length == length
    contains_all = contains.empty? || (contains.to_set.subset?(path.map { |s| s.shift.id }.to_set))
    unless length_match && contains_all
      Rails.logger.debug "⛔️ [ShiftVertex] Get Random Path did not succeed with #{path.map { |s| s.shift.id }}; length match: #{length_match} (#{length}, contains all (#{contains}): #{contains_all}"
      return nil
    end

    unless specializations.empty?
      path = path.map { |p|
        if p.specialized.empty?
          p
        else
          samples = p.specialized.filter { |template| specializations.include? template.specialization_id }
          samples += [nil] if p.shift.priority > 0
          sample = samples.sample
          sample.nil? ? p : ShiftVertex.new(sample)
        end
      }

      Rails.logger.debug "😳 paths #{path.map(&:to_s)}"
    end

    path.get_shift_ids.sort
  end


  # We know that pattern can exist at this point…
  def compute_random_path(params)
    path = []
    Rails.logger.debug "🦦 [ShiftVertex] get_rnd_next #{params}"
    length = params[:length] || max_next_steps
    contains = params[:contains] || []

    return [] if length <= 0

    path.push(self)

    contained_vertices = @nexts.map(&:clone).filter { |p| contains.include? p.shift.id } + @prev.map(&:clone).filter { |p| contains.include? p.shift.id }

    # do not execute if no contains requirements are given
    unless contains.empty?
      path += contained_vertices
    end

    next_steps = @nexts.union(@prev)
    next_steps = next_steps.filter { |vert| SchedulingUtils.max_steps_with([self, vert]) >= length } unless max_path_length > length

    path.each do |p|
      next_steps = next_steps.to_set.intersection(p.nexts.to_set.union(p.prev.to_set)).to_a
    end

    length.times do
      tmp_shift = SchedulingUtils.get_sample(next_steps, false)

      if tmp_shift.is_a? ShiftVertex
        path += [tmp_shift]
        next_steps = next_steps.intersection(tmp_shift.nexts.union(tmp_shift.prev)).to_a
      end

      break if path.length == length
    end

    path
  end

  # ====================================

  private def update_max_next_steps
    first = @nexts.min { |_, b| b.shift.start_time }
    @max_next_steps = first.nil? ? 0 : first.max_next_steps + 1
  end

  private def update_max_prev_steps
    last = @prev.max { |_, b| b.shift.end_time }
    @max_prev_steps = last.nil? ? 0 : last.max_prev_steps + 1
  end

  def to_s
    "🍺 shift #{@shift.id} [max_path_length: #{max_path_length}]  [prev=> #{@prev.map { |prev| prev.shift.id }}, max_prev_count #{max_prev_steps}] [next=> #{@nexts.map { |prev| prev.shift.id }}, max_next_count #{max_next_steps}], [specialized #{specialized.map { |v| v.id}}]"
  end

end

class Array
  def get_shift_ids
    self.map { |vertex| vertex.shift.id }
  end

  def union(other)
    self.to_set.union(other.to_set).to_a
  end

  def intersection(other)
    self.to_set.intersection(other.to_set).to_a
  end
end
