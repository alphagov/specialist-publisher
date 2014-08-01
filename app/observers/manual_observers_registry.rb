require "manual_change_note_database_exporter"

class ManualObserversRegistry
  def publication
    [
      publication_logger,
      panopticon_exporter,
      content_api_exporter,
      change_note_content_api_exporter,
    ]
  end

  def creation
    [
      panopticon_exporter,
    ]
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
          change_note: doc.change_note,
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

end
