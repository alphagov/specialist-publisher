class SpecialistDocumentDatabaseExporter

  def initialize(export_recipent, document_renderer, finder_schema, document, publication_logs)
    @export_recipent = export_recipent
    @document_renderer = document_renderer
    @finder_schema = finder_schema
    @document = document
    @publication_logs = publication_logs
  end

  def call
    export_recipent.create_or_update_by_slug!(exportable_attributes)
  end

private

  attr_reader(
    :export_recipent,
    :document_renderer,
    :finder_schema,
    :document,
    :publication_logs,
  )

  def exportable_attributes
    core_rendered_document_attributes
      .merge(details: all_other_attributes)
  end

  def all_other_attributes
    {}
      .merge(schema_defined_facet_labels)
      .merge(other_document_attributes)
      .merge({
        change_history: serialised_change_notes,
      })
  end

  def schema_defined_facet_labels
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
    rendered_document.attributes
      .slice(*core_attribute_keys)
      .merge(document_metadata)
  end

  def document_metadata
    {
      published_at: document.minor_update? ? document.last_published_at : document.updated_at,
    }
  end

  def other_document_attributes
    rendered_document.attributes.except(
      *(core_attribute_keys + excluded_attribute_keys)
    )
  end

  def core_attribute_keys
    [
      :slug,
      :title,
      :summary,
      :body,
    ]
  end

  def excluded_attribute_keys
    [
      :id,
    ]
  end

  def serialised_change_notes
    publication_logs.change_notes_for(document.slug).map { |publication|
      {
        note: publication.change_note,
        published_timestamp: publication.published_at.utc,
      }
    }
  end
end
