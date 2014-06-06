class TypesForPanopticonMappings < Mongoid::Migration
  @panopticon_mappings = Class.new do
    include Mongoid::Document
    store_in :panopticon_mappings
  end

  def self.up
    @panopticon_mappings.all.each do |mapping|
      mapping.update_attributes!(
        resource_id: mapping.read_attribute(:document_id),
        resource_type: "specialist-document",
      )
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
