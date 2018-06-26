class DocumentsTagger
  def self.tag_all(do_tag = true)
    new(do_tag).tag_all
  end

  def initialize(do_tag = true)
    @do_tag = do_tag
  end

  def tag_all
    all_documents.map do |document|
      mapped_taxon_ids = mapped_taxons(document['document_type'])
      taxons_tagged = mapped_taxon_ids.empty? ? [] : tag_to_taxons(document['content_id'], mapped_taxon_ids)
      { base_path: document['base_path'], content_id: document['content_id'], taxons: taxons_tagged }
    end
  end

private

  def tag_to_taxons(content_id, taxon_ids)
    tagged = Tagger.add_tags(content_id, @do_tag) do |existing_taxon_ids|
      existing_taxon_ids + taxon_ids
    end
    tagged ? taxon_ids : []
  end

  def all_document_types
    FinderSchema.schema_names.map(&:singularize)
  end

  def mapped_taxons(document_type)
    document_type.camelize.constantize.new.taxons
  end

  def all_documents
    Services.publishing_api.get_content_items_enum(
      publishing_app: 'specialist-publisher',
      document_type: all_document_types,
      fields: %i[content_id document_type base_path]
    ).lazy
  end
end
