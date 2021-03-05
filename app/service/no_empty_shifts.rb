class NoEmptyShifts < Constraint

  def self.is_violated(shifts, schedule)
    NoEmptyShifts.get_sanction(shifts, schedule, 100) > 0
  end

  def self.get_empty_shifts(shifts, schedule)
    array = []
    schedule.map { |_, value| array += value }

    hash = Hash.new
    shifts.each { |i| hash[i] = 0 }
    array.uniq.map { |a| hash[a] = array.count(a) }
    p hash
    return hash.filter do |key, value|
      value == 0
    end
  end

  def self.get_sanction(shifts, schedule, value_per_violation)
    p "get_empty_shifts: #{get_empty_shifts(shifts, schedule)}"
    value_per_violation * get_empty_shifts(shifts, schedule).length
  end

  def self.get_violations_hash(shifts, schedule, employees, shift_duration, value_per_violation = 10)
    hash = Hash.new

    hash[:violations] = get_empty_shifts(shifts.map(&:id), schedule)
    hash[:sanction] = get_sanction_from_array(hash[:violations], value_per_violation)
    hash
  end

  private

  def self.get_sanction_from_array(empty_shifts, value_per_violation)
    puts "empty_shifts: #{empty_shifts.length}"
    value_per_violation * empty_shifts.length
  end

end
