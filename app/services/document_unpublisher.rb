require "services"

# Unpublish a document. Also removes attachments.
class DocumentUnpublisher
  def self.unpublish(content_id, _base_path, alternative_path = nil)
    if alternative_path.blank?
      Services.publishing_api.unpublish(content_id, type: "gone")
    else
      Services.publishing_api.unpublish(
        content_id,
        type: "redirect",
        alternative_path: alternative_path,
      )
    end

    AttachmentDeleteWorker.perform_async(content_id)
  end
end
