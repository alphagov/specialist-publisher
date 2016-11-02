# Unpublish a document. Also removes attachments and removes it from search.
class DocumentUnpublisher
  def self.unpublish(content_id, base_path)
    Services.publishing_api.unpublish(content_id, type: 'gone')
    AttachmentDeleteWorker.perform_async(content_id)
    RummagerDeleteWorker.perform_async(base_path)
  end
end
