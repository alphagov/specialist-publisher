class SpecialistDocumentPublishingAPIExporter
  attr_reader :publishing_api, :document

  def initialize(publishing_api, document)
    @publishing_api = publishing_api
    @document = document
  end

  def call
    publishing_api.put_content_item(document.base_path, document.call)
  end

end
