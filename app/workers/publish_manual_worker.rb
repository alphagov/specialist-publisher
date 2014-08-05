class PublishManualWorker
  include Sidekiq::Worker

  def perform(manual_id)
    services.publish(manual_id).call
  end

private
  def services
    ManualServiceRegistry.new
  end
end
