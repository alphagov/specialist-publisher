require "url_maker"
require "rummager_indexer"
require "publishing_api_withdrawer"
require "formatters/specialist_document_publishing_api_formatter"

class AbstractSpecialistDocumentObserversRegistry
  def creation
    [
      publishing_api_exporter,
    ]
  end

  def update
    [
      publishing_api_exporter,
    ]
  end

  def publication
    [
      publication_logger,
      publishing_api_exporter,
      rummager_exporter,
      publication_alert_exporter,
    ]
  end

  def republication
    [
      publishing_api_exporter,
      rummager_exporter,
    ]
  end

  def withdrawal
    [
      publishing_api_withdrawer,
      rummager_withdrawer,
    ]
  end

private
  def publishing_api_exporter
    ->(document) {
      rendered_document = SpecialistDocumentPublishingAPIFormatter.new(
        document,
        specialist_document_renderer: SpecialistPublisherWiring.get(:specialist_document_renderer),
        publication_logs: PublicationLog
      )

      SpecialistDocumentPublishingAPIExporter.new(
        publishing_api,
        rendered_document,
        document.draft?
      ).call
    }
  end

  def publishing_api_withdrawer
    ->(document) {
      PublishingAPIWithdrawer.new(
        publishing_api: publishing_api,
        entity: document,
      ).call
    }
  end

  def rummager_exporter
    ->(document) {
      RummagerIndexer.new.add(
        format_document_for_indexing(document)
      )
    }
  end

  def rummager_withdrawer
    ->(document) {
      RummagerIndexer.new.delete(
        format_document_for_indexing(document)
      )
    }
  end

  def format_document_for_indexing(document)
    raise NotImplementedError
  end

  def email_alert_api
    SpecialistPublisherWiring.get(:email_alert_api)
  end

  def publication_alert_exporter
    ->(document) {
      if !document.minor_update
        EmailAlertExporter.new(
          email_alert_api: email_alert_api,
          formatter: publication_alert_formatter(document),
        ).call
      end
    }
  end

  def publication_alert_formatter
    raise NotImplementedError
  end

  def publication_logger
    ->(document) {
      unless document.minor_update?
        PublicationLog.create!(
          title: document.title,
          slug: document.slug,
          version_number: document.version_number,
          change_note: document.change_note,
        )
      end
    }
  end

  def url_maker
    UrlMaker.new
  end

  def publishing_api
    SpecialistPublisherWiring.get(:publishing_api)
  end
end
