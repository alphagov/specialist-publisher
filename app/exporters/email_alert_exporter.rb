class EmailAlertExporter

  def initialize(dependencies = {})
    @delivery_api = dependencies.fetch(:delivery_api)
    @formatter = dependencies.fetch(:formatter)
  end

  def call
    ensure_topic_exists
    send_notification_to_delivery_api
  end

private

  attr_reader(
    :delivery_api,
    :formatter,
  )

  def ensure_topic_exists
    delivery_api.topic(
      formatter.identifier,
      formatter.name,
    )
  end

  def send_notification_to_delivery_api
    delivery_api.notify(
      formatter.identifier,
      formatter.subject,
      formatter.body,
    )
  end
end
