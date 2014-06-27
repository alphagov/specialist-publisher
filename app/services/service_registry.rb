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
    @cma_case_builder = dependencies.fetch(:cma_case_builder)
    @aaib_report_builder = dependencies.fetch(:aaib_report_builder)
    @document_repository = dependencies.fetch(:document_repository)
    @aaib_report_repository = dependencies.fetch(:aaib_report_repository)
    @creation_listeners = dependencies.fetch(:creation_listeners)
    @aaib_report_creation_listeners = dependencies.fetch(:aaib_report_creation_listeners)
    @withdrawal_listeners = dependencies.fetch(:withdrawal_listeners)
    @document_renderer = dependencies.fetch(:document_renderer)
    @manual_repository_factory = dependencies.fetch(:manual_repository_factory)
    @manual_builder = dependencies.fetch(:manual_builder)

    @observers = dependencies.fetch(:observers)
  end

  def list_documents
    ListDocuments.new(
      document_repository,
    )
  end

  def list_aaib_reports
    ListDocuments.new(
      aaib_report_repository,
    )
  end

  def new_document
    NewDocumentService.new(
      cma_case_builder,
    )
  end

  def new_aaib_report
    NewDocumentService.new(
      aaib_report_builder,
    )
  end

  def create_aaib_report(attributes)
    CreateDocumentService.new(
      aaib_report_builder,
      aaib_report_repository,
      aaib_report_creation_listeners,
      attributes,
    )
  end

  def create_document(attributes)
    CreateDocumentService.new(
      cma_case_builder,
      document_repository,
      creation_listeners,
      attributes,
    )
  end

  def show_aaib_report(document_id)
    ShowDocumentService.new(
      aaib_report_repository,
      document_id,
    )
  end

  def show_document(document_id)
    ShowDocumentService.new(
      document_repository,
      document_id,
    )
  end

  def preview_document(document_id, attributes)
    PreviewDocumentService.new(
      document_repository,
      cma_case_builder,
      document_renderer,
      document_id,
      attributes,
    )
  end

  def preview_aaib_report(document_id, attributes)
    PreviewDocumentService.new(
      aaib_report_repository,
      aaib_report_builder,
      document_renderer,
      document_id,
      attributes,
    )
  end

  def preview_manual_document(context)
    PreviewManualDocumentService.new(
      manual_repository(context),
      cma_case_builder,
      document_renderer,
      context,
    )
  end

  def publish_aaib_report(document_id)
    PublishDocumentService.new(
      aaib_report_repository,
      observers.aaib_report_publication,
      document_id,
    )
  end

  def publish_document(document_id)
    PublishDocumentService.new(
      document_repository,
      observers.document_publication,
      document_id,
    )
  end

  def update_document(document_id, attributes)
    UpdateDocumentService.new(
      repo: document_repository,
      listeners: [],
      document_id: document_id,
      attributes: attributes,
    )
  end

  def update_aaib_report(document_id, attributes)
    UpdateDocumentService.new(
      repo: aaib_report_repository,
      listeners: [],
      document_id: document_id,
      attributes: attributes,
    )
  end

  def withdraw_document(document_id)
    WithdrawDocumentService.new(
      document_repository,
      withdrawal_listeners,
      document_id,
    )
  end

  def withdraw_aaib_report(document_id)
    WithdrawDocumentService.new(
      aaib_report_repository,
      withdrawal_listeners,
      document_id,
    )
  end

  def new_document_attachment(context)
    NewDocumentAttachmentService.new(
      document_repository,
      Attachment.method(:new),
      context,
    )
  end

  def create_document_attachment(context)
    CreateDocumentAttachmentService.new(
      document_repository,
      context,
    )
  end

  def update_document_attachment(context)
    UpdateDocumentAttachmentService.new(
      document_repository,
      context,
    )
  end

  def show_document_attachment(context)
    ShowDocumentAttachmentService.new(
      document_repository,
      context,
    )
  end

  def list_manuals(context)
    ListManualsService.new(
      manual_repository: manual_repository(context),
      context: context,
    )
  end

  def create_manual(context)
    CreateManualService.new(
      manual_repository: manual_repository(context),
      manual_builder: manual_builder,
      listeners: observers.manual_creation,
      context: context,
    )
  end

  def update_manual(context)
    UpdateManualService.new(
      manual_repository: manual_repository(context),
      context: context,
    )
  end

  def show_manual(context)
    ShowManualService.new(
      manual_repository: manual_repository(context),
      context: context,
    )
  end

  def publish_manual(context)
    PublishManualService.new(
      manual_repository: manual_repository(context),
      listeners: observers.manual_publication,
      context: context,
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
    :aaib_report_builder,
    :aaib_report_repository,
    :aaib_report_creation_listeners,
    :creation_listeners,
    :cma_case_builder,
    :document_renderer,
    :document_repository,
    :manual_builder,
    :manual_repository_factory,
    :observers,
    :withdrawal_listeners,
  )
end
