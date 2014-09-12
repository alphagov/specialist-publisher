class PublishManualWorker
  include Sidekiq::Worker

  sidekiq_options(
    # This is required to retry in the case of a FailedToPublishError
    retry: 25,
    backtrace: true,
  )

  def perform(task_id)
    task = ManualPublishTask.find(task_id)
    task.start!

    services.publish(task.manual_id, task.version_number).call

    task.finish!
  rescue GdsApi::HTTPServerError => error
    log_error(error)
    requeue_task(task_id, error)
  rescue PublishManualService::VersionMismatchError,
         GdsApi::HTTPErrorResponse => error
    log_error(error)
    abort_task(task, error)
  end

private
  def services
    ManualServiceRegistry.new
  end

  def requeue_task(manual_id, error)
    # Raise a FailedToPublishError in order for Sidekiq to catch and requeue it
    # This is more meaningful when viewing retries in the queue than an error thrown
    # further down the stack!
    raise FailedToPublishError.new("Failed to publish manual with id: #{manual_id}", error)
  end

  def abort_task(task, error)
    task.update_attribute(:error, error.message)
    task.abort!
  end

  def log_error(error)
    Airbrake.notify(error)
  end

  class FailedToPublishError < StandardError
    attr_reader :original_exception

    def initialize(message, original_exception = nil)
      super(message)
      @original_exception = original_exception
    end
  end
end
