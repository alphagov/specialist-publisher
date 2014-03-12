class SpecialistDocumentDatabaseExporter

  def initialize(active_record, document_renderer, document)
    @active_record = active_record
    @document_renderer = document_renderer
    @document = document
  end

  def call
    active_record.create!(
      rendered_document.attributes
    )
  end

private

  attr_reader :active_record, :document_renderer, :document

  def rendered_document
    document_renderer.call(document)
  end

end
