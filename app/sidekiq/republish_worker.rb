class RepublishWorker
  include Sidekiq::Job

  def perform(content_id, locale)
    RepublishService.new.call(content_id, locale)
  end
end
