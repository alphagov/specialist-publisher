class ReslugContentDesignManual < Mongoid::Migration
  @manual_records = Class.new do
    include Mongoid::Document
    store_in :manual_records
  end

  @editions = Class.new do
    include Mongoid::Document
    store_in :specialist_document_editions
  end

  OLD_SLUG = "guidance/content-design-1"
  NEW_SLUG = "guidance/content-design"

  def self.up
    manual = @manual_records.where(slug: OLD_SLUG).first

    manual.update_attribute :slug, NEW_SLUG

    manual.editions.each do |edition|
      edition["document_ids"].each do |document_id|
        @editions.where(document_id: document_id).each do |specialist_document|
          new_sd_slug = specialist_document.slug.sub(OLD_SLUG, NEW_SLUG)
          specialist_document.update_attribute :slug, new_sd_slug
        end
      end
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
