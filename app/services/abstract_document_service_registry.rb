require "specialist_publisher_wiring"
require "list_documents_service"
require "show_document_service"
require "new_document_service"
require "preview_document_service"
require "create_document_service"
require "update_document_service"
require "publish_document_service"
require "withdraw_document_service"
require "paginator"

class AbstractDocumentServiceRegistry
  def initialize(repository:, builder:, observers:)
    @repository = repository
    @builder = builder
    @observers = observers
  end

  def list(search_details)
    ListDocumentsService.new(
      RepositoryPaginator.new(document_repository),
      search_details,
    )
  end

  def show(document_id)
    ShowDocumentService.new(
      document_repository,
      document_id,
    )
  end

  def new
    NewDocumentService.new(
      document_builder,
    )
  end

  def preview(document_id, attributes)
    PreviewDocumentService.new(
      document_repository,
      document_builder,
      document_renderer,
      document_id,
      attributes,
    )
  end

  def create(attributes)
    CreateDocumentService.new(
      document_builder,
      document_repository,
      observers.creation,
      attributes,
    )
  end

  def update(document_id, attributes)
    UpdateDocumentService.new(
      repo: document_repository,
      listeners: observers.update,
      document_id: document_id,
      attributes: attributes,
    )
  end

  def publish(document_id)
    PublishDocumentService.new(
      document_repository,
      observers.publication,
      document_id,
    )
  end

  def republish(document_id)
    RepublishDocumentService.new(
      document_repository: document_repository,
      listeners: observers.republication,
      document_id: document_id,
    )
  end

  def republish_all
    -> {
      document_repository.all.each do |document|
        republish(document.id).call
      end
    }
  end

  def bulk_publish(document_id)
    PublishDocumentService.new(
      document_repository,
      observers.republication,
      document_id,
      true,
    )
  end

  def withdraw(document_id)
    WithdrawDocumentService.new(
      document_repository,
      observers.withdrawal,
      document_id,
    )
  end

private
  def document_renderer
    SpecialistPublisherWiring.get(:specialist_document_renderer)
  end

  def document_repository
    @repository
  end

  def document_builder
    @builder
  end

  attr_reader :observers
end
