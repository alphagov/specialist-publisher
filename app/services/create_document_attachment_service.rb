class CreateDocumentAttachmentService

  def initialize(document_repository, context, document_id)
    @document_repository = document_repository
    @context = context
    @document_id = document_id
  end

  def call
    attachment = document.add_attachment(attachment_params)

    document_repository.store(document)

    [document, attachment]
  end

  private

  attr_reader :document_repository, :context, :document_id

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def attachment_params
    context.params.fetch("attachment")
  end
end
