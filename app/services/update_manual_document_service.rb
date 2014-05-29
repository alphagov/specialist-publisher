class UpdateManualDocumentService
  def initialize(manual_repository, context)
    @manual_repository = manual_repository
    @context = context
  end

  def call
    document.update(document_params)

    if document.valid?
      manual_repository.store(manual)
    end

    [manual, document]
  end

  private

  attr_reader :manual_repository, :context

  def document
    @document ||= manual.documents.find { |d| d.id == document_id }
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def document_id
    context.params.fetch("id")
  end

  def manual_id
    context.params.fetch("manual_id")
  end

  def document_params
    context.params.fetch("document")
  end
end
