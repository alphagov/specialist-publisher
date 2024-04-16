require "services"

# Unpublish a document. Also removes attachments.
class DocumentUnpublisher
  def self.unpublish(content_id, locale, _base_path, alternative_path = nil)
    if alternative_path.blank?
      Services.publishing_api.unpublish(
        content_id,
        type: "gone",
        locale:,
      )
    else
      Services.publishing_api.unpublish(
        content_id,
        type: "redirect",
        locale:,
        alternative_path:,
      )
    end

    AttachmentDeleteWorker.perform_async(content_id, locale)
  end
end
