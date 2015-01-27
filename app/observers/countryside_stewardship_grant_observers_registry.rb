require "email_alert_exporter"
require "formatters/countryside_stewardship_grant_publication_alert_formatter"

class CountrysideStewardshipGrantObserversRegistry < AbstractSpecialistDocumentObserversRegistry

  private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_content_api_exporter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_rummager_deleter)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    CountrysideStewardshipGrantPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
