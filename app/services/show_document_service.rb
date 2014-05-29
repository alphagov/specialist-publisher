class ShowDocumentService

  def initialize(document_repository, context)
    @document_repository = document_repository
    @context = context
  end

  def call
    document_repository.fetch(document_id)
  end

  private

  attr_reader :document_repository, :context

  def document_id
    context.params.fetch("id")
  end

end
