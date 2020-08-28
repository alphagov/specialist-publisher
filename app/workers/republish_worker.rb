class RepublishWorker
  include Sidekiq::Worker

  def perform(content_id)
    RepublishService.new.call(content_id)
  end
end
