require "services"

class AttachmentRestoreWorker
  include Sidekiq::Worker

  def perform(content_id)
    document = Document.find(content_id)

    document.attachments.each do |attachment|
      Services.asset_api.restore_asset(attachment.id_from_url)
    end
  end
end
