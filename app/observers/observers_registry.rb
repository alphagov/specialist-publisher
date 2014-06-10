require "manual_change_note_database_exporter"

class ObserversRegistry

  def initialize(dependencies)
    @document_content_api_exporter = dependencies.fetch(:document_content_api_exporter)
    @finder_api_notifier = dependencies.fetch(:finder_api_notifier)
    @document_panopticon_registerer = dependencies.fetch(:document_panopticon_registerer)
    @manual_panopticon_registerer = dependencies.fetch(:manual_panopticon_registerer)
    @manual_document_panopticon_registerer = dependencies.fetch(:manual_document_panopticon_registerer)
    @manual_content_api_exporter = dependencies.fetch(:manual_content_api_exporter)
  end

  def document_publication
    [
      document_content_api_exporter,
      finder_api_notifier,
      document_panopticon_registerer,
    ]
  end

  def manual_publication
    [
      publication_logger,
      manual_panopticon_registerer,
      manual_content_api_exporter,
      manual_change_note_content_api_exporter,
    ]
  end

  def manual_creation
    [
      manual_panopticon_registerer,
    ]
  end

  def manual_document_creation
    [
      manual_document_panopticon_registerer,
    ]
  end

  private

  attr_reader(
    :document_content_api_exporter,
    :finder_api_notifier,
    :document_panopticon_registerer,
    :manual_panopticon_registerer,
    :manual_document_panopticon_registerer,
    :manual_content_api_exporter,
  )

  def manual_change_note_content_api_exporter
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
      PublicationLog.create!(
        title: manual.title,
        slug: manual.slug,
      )

      manual.documents.each do |doc|
        PublicationLog.create!(
          title: doc.title,
          slug: doc.slug,
          change_note: doc.change_note,
        )
      end
    }
  end
end
