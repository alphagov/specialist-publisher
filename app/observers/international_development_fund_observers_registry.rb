require "email_alert_exporter"
require "formatters/international_development_fund_publication_alert_formatter"

class InternationalDevelopmentFundObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def panopticon_exporter
    SpecialistPublisherWiring.get(:international_development_fund_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:international_development_fund_content_api_exporter)
  end

  def rummager_exporter
    SpecialistPublisherWiring.get(:international_development_fund_rummager_indexer)
  end

  def rummager_withdrawer
    SpecialistPublisherWiring.get(:international_development_fund_rummager_deleter)
  end

  def content_api_withdrawer
    SpecialistPublisherWiring.get(:specialist_document_content_api_withdrawer)
  end

  def publication_alert_formatter(document)
    InternationalDevelopmentFundPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
