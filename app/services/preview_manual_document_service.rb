class PreviewManualDocumentService
  def initialize(manual_repository, document_builder, document_renderer, context)
    @manual_repository = manual_repository
    @document_builder = document_builder
    @document_renderer = document_renderer
    @context = context
  end

  def call
    document.update(document_params)

    document_renderer.call(document)
  end

  private

  attr_reader(
    :manual_repository,
    :document_builder,
    :document_renderer,
    :context,
  )

  def document
    document_id ? existing_document : ephemeral_document
  end

  def manual
    manual_repository.fetch(manual_id)
  end

  def ephemeral_document
    document_builder.call(manual, document_params)
  end

  def existing_document
    @existing_document ||= manual.documents.find { |document|
      document.id == document_id
    }
  end

  def document_params
    context.params.fetch("document")
  end

  def document_id
    context.params.fetch("id", nil)
  end

  def manual_id
    context.params.fetch("manual_id", nil)
  end
end
