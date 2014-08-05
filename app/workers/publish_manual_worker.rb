class PublishManualWorker
  include Sidekiq::Worker

  def perform(manual_id, version_number)
    services.publish(manual_id, version_number).call
  end

private
  def services
    ManualServiceRegistry.new
  end
end
