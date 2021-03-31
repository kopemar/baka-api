class Scheduling::ShiftPatterns
  include Scheduling

  def initialize(shift_templates)
    Rails.logger.debug "🥝 new ShiftPatterns with #{shift_templates.map(&:start_time)}"
    @shift_templates = shift_templates.sort_by { |template| template.start_time }
    build_patterns
  end

  def max_length
    @max_length
  end

  def try_to_specialize(path, specializations)
    new_path = []
    path.each_with_index do |id, index|
      vertex = @hash_vertices[id]

      # prirad specializovany protejsek smeny
      specialized = vertex.specialized.filter { |shift| specializations.include?(shift.specialization_id) }

      sample = specialized.sample
      new_path[index] = sample.nil? ? path[index] : sample.id
    end

    Rails.logger.debug "🐯 PATH #{path} -> #{new_path}"
    new_path
  end

  def patterns_of_params(params)
    Rails.logger.debug "🐲 PATTERNS_OF_PARAMS #{params}"
    paths = []
    length = params[:length] || get_max_path_length(@hash_vertices)
    count = params[:count] || 1
    specializations = params[:specializations] || []

    contains = (params[:contains] || []).sort

    # todo excludes
    excludes = params[:excludes] || []

    if length > get_max_path_length(@hash_vertices)
      return paths
    end

    unless length.nil?
      possible_vertices = @vertices.filter { |vertex|
        (vertex.max_path_length >= length && (contains.empty? || contains.include?(vertex.shift.id) ||
                vertex.specialized.one? { |s|
                  # Rails.logger.debug "🦁 FILTERING specializations #{vertex.to_s} #{specializations} #{}"
                  contains.include?(s.id) && specializations.include?(s.specialization_id)
                  }
            )
        )

      }

      if !contains.is_a?(Array) || (contains.length > length)
        Rails.logger.debug "😡 Contains malformed (too long: #{contains.length > length})"
        return paths
      end

      if contains.empty? || can_exist?(contains, specializations)
        Rails.logger.debug "🌵 CAN EXIST WITH #{contains}"
        if contains.length == length
          count.times do
            paths.push(contains)
          end
          return paths
        end
      else
        Rails.logger.debug "🌵 CANNOT EXIST"
        return paths
      end
      count.times do
        Rails.logger.debug "⚽️ count times do get sample #{possible_vertices.map { |it| it.shift.id }}"
        sample = SchedulingUtils.get_sample(possible_vertices, false)

        random_path = sample.nil? ? nil : sample.random_path({ :length => length, :contains => contains, :specializations => specializations })

        if random_path.nil?
          return []
        end

        paths += [random_path]
      end

      return paths
    end

    paths
  end

  private def can_exist?(contains, specializations = [], length = contains.length)
    # all contained vertices, sorted by shift start time ASC
    vertices = contains.map { |id| @hash_vertices[id] }.sort { |v| v.shift.start_time }
    can_exist = true
    Rails.logger.debug "🐮 #{contains}"
    # first check – does the path even exist?
    vertices.each do |vertex|
      contains.each do |id|
        return false unless vertex.shift.priority > 0 || !vertex.specialized.find { |it| it.id == id && it.priority > 0 }.nil?
        unless contains_or_is(vertex, id, contains) || vertex.nexts.any? { |v| contains_or_is(v, id, contains) } || vertex.prev.any? { |v| contains_or_is(v, id, contains) }
          Rails.logger.debug "#{vertex.shift.id} 🎈 NOT contains #{id}"
          can_exist = false
          break
        end
      end
      break unless can_exist
    end

    if can_exist
      # can build pattern with enough steps?
      max_steps = SchedulingUtils.max_steps_with(vertices)
      Rails.logger.debug "🐮 can_exist but #{max_steps}"
      can_exist = max_steps >= length
    end

    can_exist
  end

  private def contains_or_is(vertex, id, contains)
    Rails.logger.debug "vertex.shift.id #{vertex.shift.id} / id: #{id}"
    (vertex.shift.id == id && !vertex.specialized.map(&:id).intersect?(contains)) || (vertex.specialized.map(&:id).include?(id) && !contains.include?(vertex.shift.id))
  end

  private def build_patterns
    hash = Hash.new
    @paths = []

    # todo make global here
    @hash_vertices = Hash.new

    hash[:start] = @shift_templates.sort_by { |s| s.start_time }.map(&:id)

    @grouped_templates = @shift_templates.group_by(&:parent_template_id)

    Rails.logger.debug "👻 Groups #{@grouped_templates}"

    map_to_paths(@grouped_templates[nil]) unless @grouped_templates[nil].nil?

    @max_length = get_max_path_length(@hash_vertices)

    @grouped_templates.each do |k, v|
      unless @hash_vertices[k].nil?
        v.each { |item|
          @hash_vertices[item.id] = @hash_vertices[k]
          @hash_vertices[k].specialized.push(item)
        }
      end

    end

    Rails.logger.debug "😘 hash vertices #{@hash_vertices.map { |k, v| "#{k} => #{v.to_s}"}}"

    # @hash_vertices = hash_vertices
    @vertices = @hash_vertices.map { |_, v| v }
  end

  private
  def map_to_paths(shift_templates)
    shift_templates.each do |template|
      @hash_vertices[template.id] = ShiftVertex.new(template)
    end

    shift_templates.each do |template|
      @hash_vertices[template.id].add_prev shift_templates.filter { |tmpl|
        shift_difference_hours(tmpl, template) > MINIMUM_BREAK_HOURS_UNDERAGE
      }.map { |prev_template| @hash_vertices[prev_template.id] }
    end

    shift_templates.reverse.each do |template|
      Rails.logger.debug "🐸 build patterns #{template.start_time}"
      @hash_vertices[template.id].add_next shift_templates.filter { |tmpl|
        shift_difference_hours(template, tmpl) > MINIMUM_BREAK_HOURS_UNDERAGE
      }.map { |next_template| @hash_vertices[next_template.id] }
    end
  end

  # todo refactor this
  def random_combination(path, length)
    set = Set.new
    path_clone = path.clone
    Rails.logger.debug "🌍 PATH #{path}"
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
