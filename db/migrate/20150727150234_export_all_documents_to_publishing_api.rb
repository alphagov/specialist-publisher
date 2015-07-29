require "lib/specialist_document_bulk_exporter"

class ExportAllDocumentsToPublishingApi < Mongoid::Migration
  def self.up
    SpecialistPublisher.document_types.each do |type|
      SpecialistDocumentBulkExporter.new(type, formatter: MigrationSpecialistDocumentPublishingAPIFormatter).call
    end
  end

  def self.down
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
