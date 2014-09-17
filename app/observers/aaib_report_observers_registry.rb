class AaibReportObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def content_api_exporter
    SpecialistPublisherWiring.get(:aaib_report_content_api_exporter)
  end

  def panopticon_exporter
    SpecialistPublisherWiring.get(:aaib_report_panopticon_registerer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:aaib_report_rummager_deleter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:aaib_report_rummager_indexer)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end
end
