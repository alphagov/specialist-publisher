class RepublishWorker
  include Sidekiq::Worker

  def perform(content_id, locale)
    RepublishService.new.call(content_id, locale)
  end
end
