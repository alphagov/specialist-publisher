class ShowDocumentService

  def initialize(document_repository, document_id)
    @document_repository = document_repository
    @document_id = document_id
  end

  def call
    document_repository.fetch(document_id)
  end

private

  attr_reader :document_repository, :document_id

end
