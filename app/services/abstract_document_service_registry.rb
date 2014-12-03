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

  # `bulk_publish` attribute is optional in both places (here and in
  # PublishDocumentService) because there are multiple entrypoints to both this
  # republish method and the PublishDocumentService, and I don't want to change
  # the method signature.
  def republish(document_id, bulk_publish = false)
    PublishDocumentService.new(
      document_repository,
      observers.republication,
      document_id,
      bulk_publish,
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
