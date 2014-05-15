require "list_documents_service"
require "show_document_service"
require "preview_document_service"
require "new_document_service"
require "publish_document_service"
require "update_document_service"
require "create_document_service"
require "withdraw_document_service"

class ServiceRegistry

  def initialize(dependencies)
    @document_builder = dependencies.fetch(:document_builder)
    @document_repository = dependencies.fetch(:document_repository)
    @publication_listeners = dependencies.fetch(:publication_listeners)
    @creation_listeners = dependencies.fetch(:creation_listeners)
    @withdrawal_listeners = dependencies.fetch(:withdrawal_listeners)
    @document_renderer = dependencies.fetch(:document_renderer)
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
    ShowDocument.new(
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
      publication_listeners,
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

  def create_manual_document(context)
    CreateDocumentService.new(
      document_builder,
      document_repository,
      [],
      context,
    )
  end

  private

  attr_reader(
    :document_builder,
    :document_repository,
    :publication_listeners,
    :creation_listeners,
    :withdrawal_listeners,
    :document_renderer,
  )
end
