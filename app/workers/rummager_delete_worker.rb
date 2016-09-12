require "services"

class RummagerDeleteWorker
  include Sidekiq::Worker

  def perform(base_path)
    Services.rummager.delete_content! base_path
  end
end
