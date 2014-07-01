class ShowDocumentAttachmentService

  def initialize(document_repository, context, document_id)
    @document_repository = document_repository
    @context = context
    @document_id = document_id
  end

  def call
    [document, attachment]
  end

  private

  attr_reader :document_repository, :context, :document_id

  def attachment
    @attachment ||= document.find_attachment_by_id(attachment_id)
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def attachment_id
    context.params.fetch("id")
  end
end
