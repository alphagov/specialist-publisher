require "specialist_publisher_wiring"
require "list_documents_service"
require "show_document_service"
require "new_document_service"
require "preview_document_service"
require "create_document_service"
require "update_document_service"
require "publish_document_service"
require "withdraw_document_service"

class CmaCaseServiceRegistry
  def list
    ListDocumentsService.new(
      cma_case_repository,
    )
  end

  def show(document_id)
    ShowDocumentService.new(
      cma_case_repository,
      document_id,
    )
  end

  def new
    NewDocumentService.new(
      cma_case_builder,
    )
  end

  def preview(document_id, attributes)
    PreviewDocumentService.new(
      cma_case_repository,
      cma_case_builder,
      document_renderer,
      document_id,
      attributes,
    )
  end

  def create(attributes)
    CreateDocumentService.new(
      cma_case_builder,
      cma_case_repository,
      observers.cma_case_creation,
      attributes,
    )
  end

  def update(document_id, attributes)
    UpdateDocumentService.new(
      repo: cma_case_repository,
      listeners: observers.cma_case_update,
      document_id: document_id,
      attributes: attributes,
    )
  end

  def publish(document_id)
    PublishDocumentService.new(
      cma_case_repository,
      observers.cma_case_publication,
      document_id,
    )
  end

  def withdraw(document_id)
    WithdrawDocumentService.new(
      cma_case_repository,
      observers.cma_case_withdrawal,
      document_id,
    )
  end

private
  def observers
    SpecialistPublisherWiring.get(:observers)
  end

  def cma_case_repository
    SpecialistPublisherWiring.get(:cma_case_repository)
  end

  def cma_case_builder
    SpecialistPublisherWiring.get(:cma_case_builder)
  end

  def document_renderer
    SpecialistPublisherWiring.get(:specialist_document_renderer)
  end
end
