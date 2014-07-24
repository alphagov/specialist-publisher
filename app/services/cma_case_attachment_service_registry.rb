class CmaCaseAttachmentServiceRegistry
  def new_attachment(document_id)
    NewDocumentAttachmentService.new(
      repository,
      Attachment.method(:new),
      document_id,
    )
  end

  def create_attachment(context, document_id)
    CreateDocumentAttachmentService.new(
      repository,
      context,
      document_id,
    )
  end

  def update_attachment(context, document_id)
    UpdateDocumentAttachmentService.new(
      repository,
      context,
      document_id,
    )
  end

  def show_attachment(context, document_id)
    ShowDocumentAttachmentService.new(
      repository,
      context,
      document_id,
    )
  end

private
  def repository
    SpecialistPublisherWiring.get(:cma_case_repository)
  end
end
