require "services"

class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload)
    begin
      Services.email_alert_api.send_alert(payload)
    rescue GdsApi::HTTPConflict
      logger.info("email-alert-api returned 409 conflict for #{payload}")
    end
  end
end
