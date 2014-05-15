class ShowDocument

  def initialize(documents_repository, context)
    @documents_repository = documents_repository
    @context = context
  end

  def call
    documents_repository.fetch(document_id)
  end

  private

  attr_reader :documents_repository, :context

  def document_id
    context.params.fetch("id")
  end

end
