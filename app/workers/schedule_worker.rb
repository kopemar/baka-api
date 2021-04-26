class ScheduleWorker
  include Sidekiq::Worker

  def perform(*args)
    Organization.all.to_a.each do |org|
      start_date = 4.weeks.from_now.monday.to_date
      end_date =  6.days.after(start_date).to_date

      SchedulingPeriod.where("start_date < ?", 3.weeks.from_now.to_date).where("end_date > ?", 3.weeks.from_now.to_date).where(submitted: false).to_a.each do |period|
        unless period.planned
          Scheduling::Scheduling.new( { id: period.id })
        end
        period.update(submitted: true)
      end

      if SchedulingPeriod.where(organization_id: org.id, start_date: start_date).empty?

        SchedulingPeriod.create!(
            start_date: start_date,
            end_date: end_date,
            organization_id: org.id
        )

        managers = Manager.where(organization_id: org.id).to_a
        NotificationHelpers.send_notification(managers, {
            notification: {
                title: "Added new scheduling period",
                body: "Get ready to plan shifts in #{start_date.to_s} - #{end_date.to_s}!"
            }
        }
        )
      end

    end
  end

end
