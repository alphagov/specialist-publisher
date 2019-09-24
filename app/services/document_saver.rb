# Save a document as draft to the publishing-api
class DocumentSaver
  def self.save(document)
    document.update_type = "major" if document.first_draft?

    presented_document = DocumentPresenter.new(document)
    presented_links = DocumentLinksPresenter.new(document)

    document.set_errors_on(document)

    Services.publishing_api.put_content(document.content_id, presented_document.to_json)
    Services.publishing_api.patch_links(document.content_id, presented_links.to_json)
  end
end
