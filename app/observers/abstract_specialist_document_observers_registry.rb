require "url_maker"

class AbstractSpecialistDocumentObserversRegistry
  def creation
    []
  end

  def update
    []
  end

  def publication
    [
      content_api_exporter,
      panopticon_exporter,
      rummager_exporter,
      document_publication_alert_exporter,
    ]
  end

  def withdrawal
    [
      content_api_withdrawer,
      panopticon_exporter,
      rummager_withdrawer,
    ]
  end

private
  def panopticon_exporter
    raise NotImplementedError
  end

  def content_api_exporter
    raise NotImplementedError
  end

  def rummager_exporter
    raise NotImplementedError
  end

  def rummager_withdrawer
    raise NotImplementedError
  end

  def content_api_withdrawer
    raise NotImplementedError
  end

  def delivery_api
    SpecialistPublisherWiring.get(:delivery_api)
  end

  def document_publication_alert_exporter
    raise NotImplementedError
  end

  def url_maker
    UrlMaker.new
  end
end
