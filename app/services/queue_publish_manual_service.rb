class QueuePublishManualService

  def initialize(async_services, manual_id)
    @async_services = async_services
    @manual_id = manual_id
  end

  def call
    async_services.publish(manual_id)
  end

private
  attr_reader(
    :async_services,
    :manual_id,
  )

end
