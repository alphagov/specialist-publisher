require "email_alert_exporter"
require "formatters/drug_safety_update_publication_alert_formatter"

class DrugSafetyUpdateObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def content_api_exporter
    SpecialistPublisherWiring.get(:drug_safety_update_content_api_exporter)
  end

  def panopticon_exporter
    SpecialistPublisherWiring.get(:drug_safety_update_panopticon_registerer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:drug_safety_update_rummager_deleter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:drug_safety_update_rummager_indexer)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    DrugSafetyUpdatePublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
