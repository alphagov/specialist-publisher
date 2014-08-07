class QueuePublishManualService

  def initialize(worker, repository, manual_id)
    @worker = worker
    @repository = repository
    @manual_id = manual_id
  end

  def call
    task = create_publish_task(manual)
    worker.perform_async(task.to_param)
    manual
  end

private

  attr_reader(
    :worker,
    :repository,
    :manual_id,
  )

  def create_publish_task(manual)
    ManualPublishTask.create!(
      manual_id: manual.id,
      version_number: manual.version_number,
    )
  end

  def manual
    @manual ||= repository.fetch(manual_id)
  end

end
