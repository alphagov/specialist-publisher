class EmailAlertExporter

  def initialize(dependencies = {})
    @delivery_api = dependencies.fetch(:delivery_api)
    @formatter = dependencies.fetch(:formatter)
  end

  def call
    send_notification_to_delivery_api
  end

private

  attr_reader(
    :delivery_api,
    :formatter,
  )

  def send_notification_to_delivery_api
    delivery_api.notify(
      formatter.identifier,
      formatter.subject,
      formatter.body,
    )
  end
end
