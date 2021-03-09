class Scheduling::ShiftPatterns

  # fixme move to another file...
  class ShiftVertex
    def initialize(shift, prev_patterns = [], next_patterns = [])
      @shifty = shift
      @prev = prev_patterns
      @next = next_patterns
    end

    def shift
      @shifty
    end

    def prev
      @prev
    end

    def next
      @next
    end

    def add_next(new_next)
      if new_next.is_a? Array
        @next += new_next
      else
        @next.push(new_next)
      end
      update_max_next_steps
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
      @max_next_steps
    end

    def max_prev_steps
      if @max_prev_steps.nil?
        update_max_prev_steps
      end
      @max_prev_steps
    end

    def max_path_length
      max_prev_steps + max_next_steps + 1
    end

    def random_path(params)
      length = params[:length]
      path = []

      if length.nil? || length > max_path_length
        # todo but low prio
      else

      end
      path += [ self ]

      prev_length = { :min_length => length - path.length - max_next_steps, :max_length => length - path.length }
      # p "🦚 prev_length #{prev_length}"
      path += get_random_prev(prev_length)
      next_length = { :min_length => length - path.length, :max_length => length - path.length }
      # p "🦚 next_length #{next_length}"
      path += get_random_next(next_length)
      # p "======== RANDOM PATH ========"
      path.map { |vertex| vertex.shift.id }.sort
    end

    protected def get_random_prev(params, path = [])
      min_length = params[:min_length] || 0

      max_length = params[:max_length] || max_prev_steps

      previous = @prev.map { |i| i.clone }.filter { |v| v.max_prev_steps >= min_length - 1 }

      tmp_shift = get_sample(previous, min_length <= 0)

      path += [tmp_shift] if tmp_shift.is_a? ShiftVertex
      if max_length > 1
        path = tmp_shift.get_random_prev({:min_length => min_length - 1, :max_length => max_length - 1 }, path) if tmp_shift.is_a? ShiftVertex
      end
      path
    end

    protected def get_random_next(params, path = [])
      min_length = params[:min_length] || 0

      max_length = params[:max_length] || max_next_steps

      next_steps = @next.map { |i| i.clone }.filter { |v| v.max_next_steps >= min_length - 1 }

      tmp_shift = get_sample(next_steps, min_length <= 0)

      path += [tmp_shift] if tmp_shift.is_a? ShiftVertex
      if max_length > 1
        path = tmp_shift.get_random_next({:min_length => min_length - 1, max_length => max_length - 1 }, path) if tmp_shift.is_a? ShiftVertex
      end
      path
    end

    private def get_sample(array, can_be_empty)
      if can_be_empty
        array.push([])
      end

      sample = array.sample

      sample.is_a?(ShiftVertex) ? sample : nil
    end

    private def update_max_next_steps
      first = @next.min { |_, b| b.shift.start_time }
      @max_next_steps = first.nil? ? 0 : first.max_next_steps + 1
    end

    private def update_max_prev_steps
      last = @prev.max { |_, b| b.shift.end_time }
      @max_prev_steps = last.nil? ? 0 : last.max_prev_steps + 1
    end

    def to_s
      "========== @shift #{@shifty.id} [max_path_length: #{max_path_length}]  [prev=> #{@prev.map { |prev| prev.shift.id}}, max_prev_count #{max_prev_steps}] [next=> #{@next.map { |prev| prev.shift.id}}, max_next_count #{max_next_steps}]"
    end

  end

  def initialize(shift_templates)
    @shift_templates = shift_templates.sort_by { |template| template.start_time }
    build_patterns
  end

  def max_length
    @max_length
  end

  def patterns_of_params(params)
    p "🐲 PATTERNS_OF_PARAMS #{params}"
    paths = []
    length = params[:length] || get_max_path_length(@hash_vertices)
    count = params[:count] || 1

    # todo smarter contains
    contains = params[:contains] || []

    # todo excludes
    excludes = params[:excludes] || []

    unless length.nil?
      vertices = @vertices.filter { |vertex| vertex.max_path_length >= length }

      count.times do
        if contains.empty?
          sample = vertices.sample
        else
          # fixme multiple contains
          sample = @hash_vertices[contains.sample]
        end

        paths += [sample.random_path({ :length => length })] unless sample.nil?
      end

      return paths
    end

    paths
  end

  private def build_patterns
    hash = Hash.new
    @paths = []

    # todo make global
    hash_vertices = Hash.new

    hash[:start] = @shift_templates.map(&:id)

    @shift_templates.each do |template|
      hash_vertices[template.id] = ShiftVertex.new(template)
    end

    @shift_templates.each do |template|
      hash_vertices[template.id].add_prev @shift_templates.filter { |tmpl|
        shift_difference_hours(tmpl, template) > 12
      }.map { |prev_template| hash_vertices[prev_template.id] }
    end

    @shift_templates.reverse.each do |template|
      hash_vertices[template.id].add_next @shift_templates.filter { |tmpl|
        shift_difference_hours(template, tmpl) > 12
      }.map { |next_template|
        hash_vertices[next_template.id]
      }
    end


    @max_length = get_max_path_length(hash_vertices)

    @hash_vertices = hash_vertices
    @vertices = @hash_vertices.map { |_, v| v }
  end
  private

  def random_combination(path, length)
    set = Set.new
    path_clone = path.clone

    length.times do
      sample = path_clone.sample
      path_clone.delete(sample)
      set.add(sample)
    end

    set.to_a
  end

  def shift_difference_hours(first, other)
    (other.start_time - first.end_time).to_d / 1.hour
  end

  private

  def get_max_path_length(hash)
    hash.map { |_, v| v.max_path_length }.max
  end

end
