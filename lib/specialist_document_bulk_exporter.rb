class SpecialistDocumentBulkExporter
  attr_reader :type, :formatter, :exporter, :logger

  def initialize(type,
                 formatter: SpecialistDocumentPublishingAPIFormatter,
                 exporter: SpecialistDocumentPublishingAPIExporter,
                 logger: Logger.new(nil))
    @formatter = formatter
    @exporter = exporter
    @logger = logger
    @type = type
  end

  def call
    export_all_editions("published")
    export_all_editions("draft")
  end

  private

  def export_all_editions(state)
    editions = specialist_document_editions.where(state: state)
    logger.info("Exporting #{editions.count} #{state} #{type} documents")

    editions.each_with_index do |edition, i|
      logger.info(i) if i % 10 == 0
      export_edition(edition)
    end
  end

  def export_edition(edition)
    document = factory.call(edition.document_id, [edition])

    rendered_document = formatter.new(
      document,
      specialist_document_renderer: renderer,
      publication_logs: PublicationLog
    )

    exporter.new(
      publishing_api,
      rendered_document,
      document.draft?
    ).call
  end

  def specialist_document_editions
    SpecialistDocumentEdition.where(document_type: type)
  end

  def factory
    entity_factories.public_send("#{type}_factory")
  end

  def entity_factories
    SpecialistPublisherWiring.get(:validatable_document_factories)
  end

  def publishing_api
    SpecialistPublisherWiring.get(:publishing_api)
  end

  def renderer
    SpecialistPublisherWiring.get(:specialist_document_renderer)
  end

  def services
    SpecialistPublisher.document_services(type)
  end
end
