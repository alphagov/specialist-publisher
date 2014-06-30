class RemoveDocumentId < Mongoid::Migration
  @mappings = Class.new do
    include Mongoid::Document
    store_in :panopticon_mappings
  end

  def self.up
    @mappings.all.each do |mapping|
      mapping.unset(:document_id)
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
