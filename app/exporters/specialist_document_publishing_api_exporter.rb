class SpecialistDocumentPublishingAPIExporter
  attr_reader :publishing_api, :document, :draft

  def initialize(publishing_api, document, draft)
    @publishing_api = publishing_api
    @document = document
    @draft = draft
  end

  def call
    if draft
      publishing_api.put_draft_content_item(document.base_path, document.call)
    else
      publishing_api.put_content_item(document.base_path, document.call)
    end
  end
end
