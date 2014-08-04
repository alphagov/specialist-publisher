class QueuePublishManualService

  def initialize(async_services, repository, manual_id)
    @async_services = async_services
    @repository = repository
    @manual_id = manual_id
  end

  def call
    async_services.publish(manual.id)
    manual
  end

private
  attr_reader(
    :async_services,
    :repository,
    :manual_id,
  )

  def manual
    @manual ||= repository.fetch(manual_id)
  end

end
