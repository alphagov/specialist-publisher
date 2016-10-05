require "services"

class AttachmentDeleteWorker
  include Sidekiq::Worker

  def perform(content_id)
    document = Document.find(content_id)

    document.attachments.each do |attachment|
      Services.asset_api.delete_asset(attachment.id_from_url)
    end
  end
end
