class SpecialistDocumentDatabaseExporter

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

  def exportable_attributes
    core_rendered_document_attributes
      .merge(details: all_other_attributes)
  end

  def all_other_attributes
    schema_defined_facets_and_labels.merge(headers: header_metadata)
  end

  def header_metadata
    rendered_document.serialized_headers
  end

  def schema_defined_facets_and_labels
    finder_schema.facets.each_with_object({}) do |facet_name, document_facets|
      document_facets[facet_name.to_sym] = rendered_document.public_send(facet_name)
      document_facets[:"#{facet_name}_label"] = label_for(facet_name)
    end
  end

  def label_for(facet_name)
    facet_value = rendered_document.public_send(facet_name)
    option_pair = finder_schema.options_for(facet_name).find do |(_, value)|
      value == facet_value
    end
    option_pair && option_pair.first
  end

  def rendered_document
    @rendered_document ||= document_renderer.call(document)
  end

  def core_rendered_document_attributes
    {
      slug: rendered_document.slug,
      title: rendered_document.title,
      summary: rendered_document.summary,
      body: rendered_document.body,
    }
  end
end
