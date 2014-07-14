require "list_documents_service"
require "show_document_service"
require "preview_document_service"
require "new_document_service"
require "publish_document_service"
require "update_document_service"
require "create_document_service"
require "withdraw_document_service"
require "show_manual_document_service"

class ServiceRegistry

  def initialize(dependencies)
    @cma_case_repository = dependencies.fetch(:cma_case_repository)
    @document_renderer = dependencies.fetch(:document_renderer)
    @manual_repository_factory = dependencies.fetch(:manual_repository_factory)
    @manual_document_builder = dependencies.fetch(:manual_document_builder)

    @observers = dependencies.fetch(:observers)
  end

  def preview_manual_document(context)
    PreviewManualDocumentService.new(
      manual_repository(context),
      manual_document_builder,
      document_renderer,
      context,
    )
  end

  def new_cma_case_attachment(document_id)
    NewDocumentAttachmentService.new(
      cma_case_repository,
      Attachment.method(:new),
      document_id,
    )
  end

  def create_cma_case_attachment(context, document_id)
    CreateDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def update_cma_case_attachment(context, document_id)
    UpdateDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def show_cma_case_attachment(context, document_id)
    ShowDocumentAttachmentService.new(
      cma_case_repository,
      context,
      document_id,
    )
  end

  def create_manual_document(context)
    CreateManualDocumentService.new(
      manual_repository: manual_repository(context),
      listeners: observers.manual_document_creation,
      context: context,
    )
  end

  def update_manual_document(context)
    UpdateManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def show_manual_document(context)
    ShowManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def new_manual_document(context)
    NewManualDocumentService.new(
      manual_repository(context),
      context,
    )
  end

  def create_manual_document_attachment(context)
    CreateManualDocumentAttachmentService.new(
      manual_repository(context),
      context,
    )
  end

  def update_manual_document_attachment(context)
    UpdateManualDocumentAttachmentService.new(
      manual_repository(context),
      context,
    )
  end

  def show_manual_document_attachment(context)
    ShowManualDocumentAttachmentService.new(
      manual_repository(context),
      context,
    )
  end

  def new_manual_document_attachment(context)
    NewManualDocumentAttachmentService.new(
      manual_repository(context),
      # TODO: This be should be created from the document or just be a form object
      Attachment.method(:new),
      context,
    )
  end

  private

  def manual_repository(context)
    manual_repository_factory.call(context.current_organisation_slug)
  end

  attr_reader(
    :document_renderer,
    :cma_case_repository,
    :manual_repository_factory,
    :manual_document_builder,
    :observers,
  )
end
