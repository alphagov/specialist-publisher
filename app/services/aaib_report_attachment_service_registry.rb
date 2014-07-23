class AaibReportAttachmentServiceRegistry

  def initialize(dependencies)
    @aaib_report_repository = dependencies.fetch(:aaib_report_repository)
  end

  def new_aaib_report_attachment(document_id)
    NewDocumentAttachmentService.new(
      aaib_report_repository,
      Attachment.method(:new),
      document_id,
    )
  end

  def create_aaib_report_attachment(context, document_id)
    CreateDocumentAttachmentService.new(
      aaib_report_repository,
      context,
      document_id,
    )
  end

  def update_aaib_report_attachment(context, document_id)
    UpdateDocumentAttachmentService.new(
      aaib_report_repository,
      context,
      document_id,
    )
  end

  def show_aaib_report_attachment(context, document_id)
    ShowDocumentAttachmentService.new(
      aaib_report_repository,
      context,
      document_id,
    )
  end

private

  attr_reader(
    :aaib_report_repository
  )
end
