class CreateDocumentAttachmentService

  def initialize(document_repository, context)
    @document_repository = document_repository
    @context = context
  end

  def call
    attachment = document.add_attachment(attachment_params)

    document_repository.store(document)

    [document, attachment]
  end

  private

  attr_reader :document_repository, :context

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def attachment_params
    context.params.fetch("attachment")
  end

  def document_id
    context.params.fetch("specialist_document_id")
  end
end
