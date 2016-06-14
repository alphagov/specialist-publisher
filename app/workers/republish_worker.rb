require "services"

class RepublishWorker
  include Sidekiq::Worker

  def perform(content_id, _=nil)

  end
end
