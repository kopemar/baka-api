class NoEmptyShifts < Constraint

  def self.is_violated(shifts, schedule)
    array = []
    schedule.map { |_, value| array += value }

    hash = Hash.new
    shifts.each { |i| hash[i] = 0 }
    array.uniq.map { |a| hash[a] = array.count(a) }

    hash.any? { |_, value| value == 0 }
  end

end
