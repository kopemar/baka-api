class ShiftPatterns

  def initialize(shift_templates)
    @shift_templates = shift_templates.sort_by { |template| template.start_time }
    build_patterns
  end

  def patterns_of_length(length)
    tmp_paths = @paths.clone.filter{ |path| path.length >= length }

    paths = []
    tmp_paths.each { |path| path.combination(length).each { |combination| paths.push(combination) } }
    paths
  end

  private def build_patterns
    hash = Hash.new
    @paths = []

    hash[:start] = @shift_templates.map(&:id)

    @shift_templates.each { |template| hash[template.id] = @shift_templates.filter { |tmpl|
      shift_difference_hours(template, tmpl) > 12
    }.map(&:id) }

    reduce_to_paths(hash)

    hash[:start].map { |point| find_path(hash, [point]) }
  end

  private def reduce_to_paths(hash)
    reduce_to_hash_recursively(hash, :start, hash[:start])
  end

  private def reduce_to_hash_recursively(original_hash, parent_index, parent)
    original_hash[parent_index].each_with_index do |start_key, index|
      break unless index < original_hash[parent_index].length
      array = original_hash[start_key]
      parent = remove_duplicates_from_parent(parent, array)
    end
    original_hash[parent_index] = parent
    original_hash[parent_index].each_with_index do |start_key|
      original_hash = reduce_to_hash_recursively(original_hash, start_key, original_hash[start_key])
    end
    original_hash
  end

  private def remove_duplicates_from_parent(parent, child)
    parent.filter { |item| !child.include? item }
  end

  private def shift_difference_hours(first, other)
    (other.start_time - first.end_time).to_d / 1.hour
  end

  private def find_path(hash, partial_path)
    if hash[partial_path.last].empty?
      @paths.push(partial_path)
      return
    end
    hash[partial_path.last].each_with_index do |value|
      tmp_path = partial_path.clone
      find_path(hash, tmp_path.push(value))
    end
  end
end
