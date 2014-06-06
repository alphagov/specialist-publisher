class AddTypeToDocuments < Mongoid::Migration
  @specialist_document_editions = Class.new do
    include Mongoid::Document
    store_in :specialist_document_editions
  end

  def self.up
    @specialist_document_editions
      .where(document_type: nil)
      .each do |document|
        document.update_attributes!(
          document_type: "cma_case",
        )
      end
  end

  def self.down
    raise IrreversibleMigration
  end
end
