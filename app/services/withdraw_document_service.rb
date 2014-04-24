class WithdrawDocumentService
  def initialize(document_repository, listeners, context)
    @document_repository = document_repository
    @listeners = listeners
    @context = context
  end

  def call
    document.withdraw!
    document
  end

  private

  attr_reader :document_repository, :listeners, :context

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def document_id
    context.params.fetch("id")
  end
end
