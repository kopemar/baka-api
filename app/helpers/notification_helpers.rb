require 'fcm'

class NotificationHelpers
  #
  # http://tech.patientslikeme.com/2017/12/07/firebase-cloud-messenger.html
  # @param options = {
  #   notification: {
  #     title: "Title text",
  #     body: "Body text"
  #   }
  # }
  def self.send_notification(users, options)

    server_key = Rails.application.credentials.firebase[:key]
    fcm_client = FCM.new(server_key)

    tokens = FcmToken.select(:fcm_token).where(user_id: users.map(&:id)).map(&:fcm_token).to_a
    Rails.logger.debug "🐼 Gonna try to send notification to users #{users.map(&:username)} "

    tokens.each_slice(20) do |ids|
      fcm_client.send(ids, options)
      Rails.logger.debug "🐼 Sent notification to users #{ids} "
    end
  end
end
