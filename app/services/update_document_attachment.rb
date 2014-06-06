class UpdateDocumentAttachmentService

  def initialize(document_repository, context)
    @document_repository = document_repository
    @context = context
  end

  def call
    attachment.update_attributes(attachment_params)

    document_repository.store(document)

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

  def attachment_params
    context.params
      .fetch("attachment")
      .merge("filename" => uploaded_filename)
  end

  def uploaded_filename
    context.params
      .fetch("attachment")
      .fetch("file")
      .original_filename
  end

  def document_id
    context.params.fetch("specialist_document_id")
  end

  def attachment_id
    context.params.fetch("id")
  end
end
