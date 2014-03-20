class SpecialistDocumentExporter

  def initialize(export_recipent, document_renderer, finder_schema, document)
    @export_recipent = export_recipent
    @document_renderer = document_renderer
    @finder_schema = finder_schema
    @document = document
  end

  def call
    export_recipent.create_or_update_by_slug!(exportable_attributes)
  end

private

  attr_reader :export_recipent, :document_renderer, :finder_schema, :document

  def rendered_document
    @rendered_document ||= document_renderer.call(document)
  end

  def rendered_document_attributes
    rendered_document.attributes
  end

  def exportable_attributes
    remove_id_key(rendered_document_attributes)
      .merge(document_id_field)
      .merge(option_labels)
  end

  def option_labels
    finder_schema.facets.each_with_object({}) do |facet_name, labels|
      labels[:"#{facet_name}_label"] = label_for(facet_name)
    end
  end

  def label_for(facet_name)
    facet_value = rendered_document_attributes.fetch(facet_name)
    option_pair = finder_schema.options_for(facet_name).find do |(label, value)|
      value == facet_value
    end
    option_pair && option_pair.first
  end

  def document_id_field
    { document_id: rendered_document_attributes.fetch(:id) }
  end

  def remove_id_key(hash)
    hash.reject { |k, _| k == :id }
  end
end
