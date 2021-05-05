class TestDataA
  def self.demand_1
    [0, 1, 2, 4, 5, 7, 8, 11, 15, 18, 20]
  end

  def self.demand_2
    [3, 6, 9, 10, 12, 14, 17, 19]
  end

  def self.demand_3
    [16]
  end

  def self.demand_4
    [13]
  end

  def self.specialization_s1
    [0, 3, 6, 9, 12, 15, 18]
  end

  def self.specialization_s1_demand_1
    [15, 18]
  end

  def self.specialization_s1_demand_2
    [0, 3, 6, 9, 12]
  end

  def self.specialization_s2
    [1, 3, 4, 6, 7, 9, 10, 12, 13, 15, 16, 18, 19]
  end

  def self.specialization_s2_demand_1
    [1, 3, 4, 6, 7, 9, 16, 18, 19]
  end

  def self.specialization_s2_demand_2
    [10]
  end

  def self.specialization_s2_demand_3
    [12, 13, 15]
  end
end
