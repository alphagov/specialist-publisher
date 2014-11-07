class EmailAlertExporter

  def initialize(dependencies = {})
    @email_alert_api = dependencies.fetch(:email_alert_api)
    @formatter = dependencies.fetch(:formatter)
  end

  def call
    email_alert_api.send_alert(
      "subject" => formatter.subject,
      "body" => formatter.body,
      "tags" => formatter.tags,
    )
  end

private

  attr_reader(
    :email_alert_api,
    :formatter,
  )
end
