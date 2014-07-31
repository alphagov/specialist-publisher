class AaibReportObserversRegistry
  def publication
    [
      content_api_exporter,
      finder_api_notifier,
      panopticon_registerer,
      rummager_indexer,
    ]
  end

  def update
    []
  end

  def creation
    [
      panopticon_registerer,
    ]
  end

  def withdrawal
    [
      specialist_document_content_api_withdrawer,
      finder_api_withdrawer,
      panopticon_registerer,
      rummager_deleter,
    ]
  end

private
  def content_api_exporter
    SpecialistPublisherWiring.get(:aaib_report_content_api_exporter)
  end

  def panopticon_registerer
    SpecialistPublisherWiring.get(:aaib_report_panopticon_registerer)
  end

  def rummager_deleter
    SpecialistPublisherWiring.get(:aaib_report_rummager_deleter)
  end

  def rummager_indexer
    SpecialistPublisherWiring.get(:aaib_report_rummager_indexer)
  end

  def finder_api_notifier
    SpecialistPublisherWiring.get(:finder_api_notifier)
  end

  def finder_api_withdrawer
    SpecialistPublisherWiring.get(:finder_api_withdrawer)
  end

  def specialist_document_content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end
end
