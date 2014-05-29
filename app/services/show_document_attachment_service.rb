class ShowDocumentAttachmentService

  def initialize(document_repository, context)
    @document_repository = document_repository
    @context = context
  end

  def call
    [document, attachment]
  end

  private

  attr_reader :document_repository, :context

  def attachment
    @attachment ||= document.find_attachment_by_id(attachment_id)
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def document_id
    context.params.fetch("specialist_document_id")
  end

  def attachment_id
    context.params.fetch("id")
  end
end
