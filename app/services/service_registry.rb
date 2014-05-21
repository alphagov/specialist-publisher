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
    @document_builder = dependencies.fetch(:document_builder)
    @document_repository = dependencies.fetch(:document_repository)
    @creation_listeners = dependencies.fetch(:creation_listeners)
    @withdrawal_listeners = dependencies.fetch(:withdrawal_listeners)
    @document_renderer = dependencies.fetch(:document_renderer)
    @manual_repository_factory = dependencies.fetch(:manual_repository_factory)
    @plain_manual_repository_factory = dependencies.fetch(:plain_manual_repository_factory)
    @manual_document_builder = dependencies.fetch(:manual_document_builder)

    @observers = dependencies.fetch(:observers)
  end

  def list_documents(context)
    ListDocuments.new(
      document_repository,
    )
  end

  def new_document(context)
    NewDocumentService.new(
      document_builder,
      context,
    )
  end

  def create_document(context)
    CreateDocumentService.new(
      document_builder,
      document_repository,
      creation_listeners,
      context,
    )
  end

  def show_document(context)
    ShowDocumentService.new(
      document_repository,
      context,
    )
  end

  def preview_document(context)
    PreviewDocumentService.new(
      document_repository,
      document_builder,
      document_renderer,
      context,
    )
  end

  def publish_document(context)
    PublishDocumentService.new(
      document_repository,
      observers.document_publication,
      context,
    )
  end

  def update_document(context)
    UpdateDocumentService.new(
      document_repository,
      [],
      context,
    )
  end

  def withdraw_document(context)
    WithdrawDocumentService.new(
      document_repository,
      withdrawal_listeners,
      context,
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
      manual_repository: plain_manual_repository(context),
      manual_builder: manual_builder,
      context: context,
    )
  end

  def update_manual(context)
    UpdateManualService.new(
      manual_repository: plain_manual_repository(context),
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
      manual_repository(context),
      manual_document_builder,
      context,
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
      manual_document_builder,
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

  def plain_manual_repository(context)
    plain_manual_repository_factory.call(
      organisation_slug: context.current_organisation_slug,
    )
  end

  def manual_builder
    ->(attrs) {
      default = {
        id: SecureRandom.uuid,
        title: "",
        summary: "",
        organisation_slug: "",
        updated_at: "",
      }

      Manual.new(default.merge(attrs))
    }
  end

  attr_reader(
    :observers,
    :document_builder,
    :document_repository,
    :creation_listeners,
    :withdrawal_listeners,
    :document_renderer,

    :manual_repository_factory,
    :plain_manual_repository_factory,
    :manual_document_builder,
  )
end
