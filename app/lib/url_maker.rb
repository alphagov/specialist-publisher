class UrlMaker
  attr_reader :plek

  def initialize(plek: plek)
    @plek = plek
  end

  def published_specialist_document_path(document)
    [plek.find('specialist-frontend'), document.slug].join("/")
  end
end
