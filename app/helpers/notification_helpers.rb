require 'fcm'

class NotificationHelpers
  def self.send_notification(users, options)
    server_key = Rails.application.credentials.firebase[:key]
    fcm_client = FCM.new(server_key)

    tokens = []

    users.each { |u| tokens += u.fcm_token }

    tokens.each_slice(20) do |ids|
      fcm_client.send(ids, options)
      Rails.logger.debug "🐼 Sent notification to users. "
    end
  end
end
