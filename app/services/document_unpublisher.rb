# Unpublish a document. Also removes attachments.
class DocumentUnpublisher
  AlternativeContentNotFound = Class.new(StandardError)

  def self.unpublish(content_id, _base_path, alternative_path = nil)
    if alternative_path.blank?
      Services.publishing_api.unpublish(content_id, type: 'gone')

    elsif Services.publishing_api.lookup_content_id(base_path: alternative_path)
      Services.publishing_api.unpublish(
        content_id,
        type: 'redirect',
        alternative_path: alternative_path,
      )

    else
      raise AlternativeContentNotFound, 'Alternative content not found at ' \
                                          "the path '#{alternative_path}'"
    end

    AttachmentDeleteWorker.perform_async(content_id)
  end
end
