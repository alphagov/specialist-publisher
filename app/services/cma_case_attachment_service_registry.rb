class CmaCaseAttachmentServiceRegistry

  def initialize(dependencies)
    @cma_case_repository = dependencies.fetch(:cma_case_repository)
  end

  def new_attachment(document_id)
    NewDocumentAttachmentService.new(
      cma_case_repository,
      Attachment.method(:new),
      document_id,
    )
  end

  def create_attachment(context, document_id)
    CreateDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def update_attachment(context, document_id)
    UpdateDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def show_attachment(context, document_id)
    ShowDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

private

  attr_reader(
    :cma_case_repository
  )
end
