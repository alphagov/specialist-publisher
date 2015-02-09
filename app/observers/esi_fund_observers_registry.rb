require "email_alert_exporter"
require "formatters/esi_fund_publication_alert_formatter"

class EsiFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

  private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:esi_fund_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:esi_fund_content_api_exporter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:esi_fund_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:esi_fund_rummager_deleter)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    EsiFundPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
