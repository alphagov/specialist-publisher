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
end
