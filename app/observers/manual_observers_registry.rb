require "gds_api/publishing_api"
require "gds_api/organisations"
require "manual_change_note_database_exporter"
require "manual_publishing_api_exporter"
require "manual_section_publishing_api_exporter"

class ManualObserversRegistry
  def publication
    [
      publication_logger,
      panopticon_exporter,
      content_api_exporter,
      change_note_content_api_exporter,
      rummager_exporter,
      publishing_api_exporter,
    ]
  end

  def creation
    []
  end

private
  def change_note_content_api_exporter
    ->(manual) {
      ManualChangeNoteDatabaseExporter.new(
        export_target: ManualChangeHistory,
        publication_logs: PublicationLog,
        manual: manual,
      ).call
    }
  end

  def publication_logger
    ->(manual) {
      manual.documents.each do |doc|
        PublicationLog.create!(
          title: doc.title,
          slug: doc.slug,
          version_number: doc.version_number,
          change_note: doc.change_note,
        )
      end
    }
  end

  def rummager_exporter
    ->(manual) {
      indexer = RummagerIndexer.new

      indexer.add(
        ManualIndexableFormatter.new(manual)
      )

      manual.documents.each do |section|
        indexer.add(
          ManualSectionIndexableFormatter.new(
            MarkdownAttachmentProcessor.new(section),
            manual,
          )
        )
      end
    }
  end

  def panopticon_exporter
    SpecialistPublisherWiring.get(:manual_panopticon_registerer)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:manual_and_documents_content_api_exporter)
  end

  def publishing_api_exporter
    ->(manual) {
      manual_renderer = SpecialistPublisherWiring.get(:manual_renderer)
      ManualPublishingAPIExporter.new(
        publishing_api,
        organisations_api,
        manual_renderer,
        PublicationLog,
        manual
      ).call

      document_renderer = SpecialistPublisherWiring.get(:specialist_document_renderer)
      manual.documents.each do |document|
        ManualSectionPublishingAPIExporter.new(
          publishing_api,
          organisations_api,
          document_renderer,
          manual,
          document
        ).call
      end
    }
  end

  def publishing_api
    GdsApi::PublishingApi.new(Plek.new.find("publishing-api"))
  end

  def organisations_api
    GdsApi::Organisations.new(ORGANISATIONS_API_BASE_PATH)
  end
end
