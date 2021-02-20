class SchedulingService < ApplicationService
  class SchedulingError < StandardError; end

  def initialize(params)
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      period_id = @params["id"]
      if period_id.nil?
        raise SchedulingError.new("No ID of scheduling period")
      end
      scheduling_period = SchedulingPeriod.where(id: period_id).first

      if scheduling_period.nil?
        raise SchedulingError.new("Invalid ID of scheduling period")
      end

      days = scheduling_period.scheduling_units
      # todo
    end
  end



end