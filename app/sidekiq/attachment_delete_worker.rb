require "services"

class AttachmentDeleteWorker
  include Sidekiq::Job

  def perform(content_id, locale)
    document = Document.find(content_id, locale)

    document.attachments.each do |attachment|
      Services.asset_api.delete_asset(attachment.id_from_url)
    end
  end
end
