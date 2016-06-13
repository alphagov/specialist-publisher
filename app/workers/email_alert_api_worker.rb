require "services"

class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload, _ = nil)
    Services.email_alert_api.send_alert(payload)
  end
end
