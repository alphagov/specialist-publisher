class SpecialistDocumentExporter

  def initialize(export_recipent, document_renderer, document)
    @export_recipent = export_recipent
    @document_renderer = document_renderer
    @document = document
  end

  def call
    export_recipent.create_or_update_by_slug!(exportable_attributes)
  end

private

  attr_reader :export_recipent, :document_renderer, :document

  def rendered_document
    @rendered_document ||= document_renderer.call(document)
  end

  def rendered_document_attributes
    rendered_document.attributes
  end

  def exportable_attributes
    remove_id_key(rendered_document_attributes)
      .merge(document_id_field)
  end

  def document_id_field
    { document_id: rendered_document_attributes.fetch(:id) }
  end

  def remove_id_key(hash)
    hash.reject { |k, _| k == :id }
  end
end
