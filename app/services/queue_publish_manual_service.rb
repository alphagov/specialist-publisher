class QueuePublishManualService

  def initialize(async_services, repository, publication_logger, manual_id)
    @async_services = async_services
    @repository = repository
    @manual_id = manual_id
    @publication_logger = publication_logger
  end

  def call
    async_services.publish(manual.id, manual.version_number)
    publication_logger.call(manual).call
    manual
  end

private
  attr_reader(
    :async_services,
    :repository,
    :publication_logger,
    :manual_id,
  )

  def manual
    @manual ||= repository.fetch(manual_id)
  end

end
