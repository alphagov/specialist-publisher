require "create_manual_document_attachment_service"
require "update_manual_document_attachment_service"
require "show_manual_document_attachment_service"
require "new_manual_document_attachment_service"

class AbstractManualDocumentAttachmentServiceRegistry
  def create(context)
    CreateManualDocumentAttachmentService.new(
      repository,
      context,
    )
  end

  def update(context)
    UpdateManualDocumentAttachmentService.new(
      repository,
      context,
    )
  end

  def show(context)
    ShowManualDocumentAttachmentService.new(
      repository,
      context,
    )
  end

  def new(context)
    NewManualDocumentAttachmentService.new(
      repository,
      # TODO: This be should be created from the document or just be a form object
      Attachment.method(:new),
      context,
    )
  end
end
