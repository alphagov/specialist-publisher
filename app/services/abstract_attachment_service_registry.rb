class AbstractAttachmentServiceRegistry
  def new(document_id)
    NewDocumentAttachmentService.new(
      repository,
      Attachment.method(:new),
      document_id,
    )
  end

  def create(context, document_id)
    CreateDocumentAttachmentService.new(
      repository,
      context,
      document_id,
    )
  end

  def update(context, document_id)
    UpdateDocumentAttachmentService.new(
      repository,
      context,
      document_id,
    )
  end

  def show(context, document_id)
    ShowDocumentAttachmentService.new(
      repository,
      context,
      document_id,
    )
  end

private
  def repository
    raise NotImplementedError
  end
end
