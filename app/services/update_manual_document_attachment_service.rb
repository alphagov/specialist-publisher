class UpdateManualDocumentAttachmentService

  def initialize(manual_repository, context)
    @manual_repository = manual_repository
    @context = context
  end

  def call
    attachment.update_attributes(attachment_params)

    manual_repository.store(manual)

    [manual, document, attachment]
  end

  private

  attr_reader :manual_repository, :context

  def attachment
    @attachment ||= document.find_attachment_by_id(attachment_id)
  end

  def document
    @document ||= manual.documents.find { |d| d.id == document_id }
  end

  def manual
    @manual ||= manual_repository.fetch(manual_id)
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

  def manual_id
    context.params.fetch("manual_id")
  end

  def document_id
    context.params.fetch("document_id")
  end

  def attachment_id
    context.params.fetch("id")
  end
end
