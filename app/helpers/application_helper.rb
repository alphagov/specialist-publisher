module ApplicationHelper

  def facet_options(form, facet)
    form.object.facet_options(facet)
  end

  def published_document_path(document)
    Plek.current.find("website-root") + document.base_path
  end
end
