require "specialist_document_bulk_exporter"
require Rails.root.join("app/exporters/formatters/specialist_document_publishing_api_formatter")

namespace :publishing_api do
  desc "Publish all Finders to the Publishing API"
  task :publish_finders do
    require "publishing_api_finder_publisher"

    require "multi_json"

    metadata = Dir.glob("finders/metadata/**/*.json").map do |file_path|
      {
        file: MultiJson.load(File.read(file_path)),
        timestamp: File.mtime(file_path)
      }
    end

    schemae = Dir.glob("finders/schemas/**/*.json").map do |file_path|
      {
        file: MultiJson.load(File.read(file_path)),
        timestamp: File.mtime(file_path)
      }
    end

    PublishingApiFinderPublisher.new(metadata, schemae).call
  end

  task :publish_documents_as_placeholders => :environment do
    SpecialistPublisher.document_types.each do |type|
      SpecialistDocumentBulkExporter.new(
        type,
        formatter: MigrationSpecialistDocumentPublishingAPIFormatter,
        logger: Logger.new(STDOUT)
      ).call
    end
  end

  namespace :draft do
    desc "Export all manuals and manual documents to the draft publishing api"
    task :publish_manuals => :environment do
      ManualPublishingApiBulkDraftExporter.new(SpecialistPublisherWiring, logger: Logger.new(STDOUT)).export_all
    end
  end
end

class MigrationSpecialistDocumentPublishingAPIFormatter < SpecialistDocumentPublishingAPIFormatter
  def call
    # To speed up the export, we want to avoid re-registering routes for existing
    # published documents, so use a custom formatter subclass that overrides the
    # format field to be "placeholder_specialist_document". Draft documents *do*
    # need to register routes though, since they will not exist for unpublished
    # documents.
    super.merge(update_type: "republish").tap do |data|
      if specialist_document.published?
        data[:format] = "placeholder_specialist_document"
      end
    end
  end
end
