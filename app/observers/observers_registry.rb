require "manual_change_note_database_exporter"

class ObserversRegistry

  def initialize(dependencies)
    @document_content_api_exporter = dependencies.fetch(:document_content_api_exporter)
    @aaib_report_content_api_exporter = dependencies.fetch(:aaib_report_content_api_exporter)
    @finder_api_notifier = dependencies.fetch(:finder_api_notifier)
    @cma_case_panopticon_registerer = dependencies.fetch(:cma_case_panopticon_registerer)
    @aaib_report_panopticon_registerer = dependencies.fetch(:aaib_report_panopticon_registerer)
    @manual_panopticon_registerer = dependencies.fetch(:manual_panopticon_registerer)
    @manual_document_panopticon_registerer = dependencies.fetch(:manual_document_panopticon_registerer)
    @manual_content_api_exporter = dependencies.fetch(:manual_content_api_exporter)
    @cma_case_rummager_indexer = dependencies.fetch(:cma_case_rummager_indexer)
    @aaib_report_rummager_indexer = dependencies.fetch(:aaib_report_rummager_indexer)
  end

  def cma_case_publication
    [
      document_content_api_exporter,
      finder_api_notifier,
      cma_case_panopticon_registerer,
      cma_case_rummager_indexer,
    ]
  end

  def aaib_report_publication
    [
      aaib_report_content_api_exporter,
      finder_api_notifier,
      aaib_report_panopticon_registerer,
      aaib_report_rummager_indexer,
    ]
  end

  def cma_case_update
    [
      cma_case_panopticon_registerer,
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
    :aaib_report_content_api_exporter,
    :finder_api_notifier,
    :cma_case_panopticon_registerer,
    :aaib_report_panopticon_registerer,
    :manual_panopticon_registerer,
    :manual_document_panopticon_registerer,
    :manual_content_api_exporter,
    :cma_case_rummager_indexer,
    :aaib_report_rummager_indexer,
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
