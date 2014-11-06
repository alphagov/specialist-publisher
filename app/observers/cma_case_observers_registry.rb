require "email_alert_exporter"
require "formatters/cma_case_publication_alert_formatter"

class CmaCaseObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:cma_case_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:cma_case_content_api_exporter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:cma_case_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:cma_case_rummager_deleter)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    CmaCasePublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
