class CreateManualDocumentService
  def initialize(manual_repository, manual_document_builder, context)
    @manual_repository = manual_repository
    @document_builder = manual_document_builder
    @context = context
  end

  def call
    if new_document.valid?
      manual.add_document(new_document)
      manual_repository.store(manual)
    end

    [manual, new_document]
  end

  private

  attr_reader :manual_repository, :document_builder, :context

  def new_document
    @new_document ||= document_builder.call(document_params)
  end

  def manual
    @manual ||= manual_repository.fetch(context.params.fetch("manual_id"))
  end

  def document_params
    context.params.fetch("document")
  end
end
