class ScheduleWorker
  include Sidekiq::Worker

  def perform(*args)
    Organization.all.to_a.each do |org|
      SchedulingPeriod.create!(
          start_date: 4.weeks.from_now.monday.to_date,
          end_date: 4.weeks.from_now.sunday.to_date,
          organization: org
      )

      managers = Manager.where(organization_id: org.id).to_a
      NotificationHelpers.send_notification(managers, {
          notification: {
              title: "Send notification to managers",
              body: "If you see this, I succeeded 🙃"
          }
      }
      )

    end
  end

end
