class PublishManualWorker
  include Sidekiq::Worker

  def perform(task_id)
    task = ManualPublishTask.find(task_id)
    services.publish(task.manual_id, task.version_number).call
  end

private
  def services
    ManualServiceRegistry.new
  end
end
