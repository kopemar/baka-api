class DemandService < ApplicationService
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def call
    demand_from_db = Demand.between(@start_date, @end_date).to_a
    demand = Hash.new

    (@end_date - @start_date).to_i.times do |i|
      day = i.days.after(@start_date)
      demand[day] = demand_from_db.select { |d| d.start_date == day || d.end_date == day }.sort_by{ |d| d.start_time }
      daily_demand = demand[day]
      len = daily_demand.length

      if len != 0
        if daily_demand[0].start_time > day.midnight
          demand[day].push(Demand.create(start_time: day.midnight, end_time: daily_demand[0].start_time, demand: 3))
        end
      else
        demand[day].push(Demand.create(start_time: day.midnight, end_time: 1.day.after(day).midnight, demand: 3))
      end

      unless len < 2
        if daily_demand[len - 1].end_time < 1.days.after(day).midnight
          demand[day].push(Demand.create(start_time: daily_demand[len - 1].end_time, end_time: 1.days.after(day).midnight, demand: 3))
        end
      end

      len.times{ |index|
        if index < daily_demand.length - 1
          unless daily_demand[index].end_time == daily_demand[index + 1].start_time
            if index + 1 < len
              demand[day].push(Demand.create(start_time: daily_demand[index].end_time, end_time: daily_demand[index + 1].start_time, demand: 3))
            end
          end
        end
      }
      daily_demand.sort_by { |d| d.start_time }
    end
    demand
  end
end