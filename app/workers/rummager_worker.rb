require "services"

class RummagerWorker
  include Sidekiq::Worker

  def perform(document_type, base_path, payload)
    payload.symbolize_keys!
    Services.rummager.add_document(document_type, base_path, payload)
  end
end
