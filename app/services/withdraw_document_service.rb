class WithdrawDocumentService
  def initialize(document_repository, listeners, context)
    @document_repository = document_repository
    @listeners = listeners
    @context = context
  end

  def call
    withdraw
    persist
    notify_listeners

    document
  end

  private

  attr_reader :document_repository, :listeners, :context

  def withdraw
    document.withdraw!
  end

  def persist
    document_repository.store!(document)
  end

  def notify_listeners
    listeners.each { |l| l.call(document) }
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def document_id
    context.params.fetch("id")
  end
end
