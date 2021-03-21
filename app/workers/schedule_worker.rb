class ScheduleWorker
  include Sidekiq::Worker

  def perform(*args)
    Employee.notify_all
  end
end
