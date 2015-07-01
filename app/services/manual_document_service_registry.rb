require "preview_manual_document_service"
require "create_manual_document_service"
require "update_manual_document_service"
require "show_manual_document_service"
require "new_manual_document_service"
require "list_manual_documents_service"
require "reorder_manual_documents_service"
require "remove_manual_document_service"

class ManualDocumentServiceRegistry
  def preview(context)
    PreviewManualDocumentService.new(
      manual_repository,
      manual_document_builder,
      document_renderer,
      context,
    )
  end

  def create(context)
    CreateManualDocumentService.new(
      manual_repository: manual_repository,
      listeners: [],
      context: context,
    )
  end

  def update(context)
    UpdateManualDocumentService.new(
      manual_repository,
      context,
    )
  end

  def show(context)
    ShowManualDocumentService.new(
      manual_repository,
      context,
    )
  end

  def new(context)
    NewManualDocumentService.new(
      manual_repository,
      context,
    )
  end

  def list(context)
    ListManualDocumentsService.new(
      manual_repository,
      context,
    )
  end

  def update_order(context)
    ReorderManualDocumentsService.new(
      manual_repository,
      context,
    )
  end

  def remove(context)
    RemoveManualDocumentService.new(
      manual_repository,
      context,
    )
  end

private
  def document_renderer
    SpecialistPublisherWiring.get(:specialist_document_renderer)
  end

  def manual_document_builder
    SpecialistPublisherWiring.get(:manual_document_builder)
  end

  def manual_repository
    SpecialistPublisherWiring.get(:repository_registry).manual_repository
  end
end
