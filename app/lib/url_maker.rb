class UrlMaker
  def published_specialist_document_path(document)
    [plek.website_root, document.slug].join("/")
  end

private
  def plek
    @plek ||= Plek.current
  end
end
