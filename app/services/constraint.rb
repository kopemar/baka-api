class Constraint

  def initialize(*args)
    super()
  end

  def self.get_violations_hash
    { sanction: 0, violations: {} }
  end

end
