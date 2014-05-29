class CreateManualDocumentAttachmentService

  def initialize(manual_repository, context)
    @manual_repository = manual_repository
    @context = context
  end

  def call
    attachment = document.add_attachment(attachment_params)

    manual_repository.store(manual)

    [manual, document, attachment]
  end

  private

  attr_reader :manual_repository, :context

  def document
    @document ||= manual.documents.find { |d| d.id == document_id }
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
  end

  def attachment_params
    context.params.fetch("attachment")
  end

  def manual_id
    context.params.fetch("manual_id")
  end

  def document_id
    context.params.fetch("document_id")
  end
end
