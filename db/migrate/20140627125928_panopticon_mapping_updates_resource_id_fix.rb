class PanopticonMappingUpdatesResourceIdFix < Mongoid::Migration
  @mappings = Class.new do
    include Mongoid::Document
    store_in :panopticon_mappings
  end

  def self.up
    @mappings.where(slug: /\/updates$/).each do |mapping|
      mapping.update_attribute(:resource_id, "#{mapping.resource_id}/updates")
    end
  end

  def self.down
    @mappings.where(slug: /\/updates$/).each do |mapping|
      mapping.update_attribute(:resource_id, mapping.resource_id.gsub(/\/updates$/, ""))
    end
  end
end
