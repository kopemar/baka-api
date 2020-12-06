class DemandService < ApplicationService
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def call
    # demand = Demand.between(@start_date, @end_date).to_a

  end
end