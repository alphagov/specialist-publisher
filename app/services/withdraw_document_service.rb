class WithdrawDocumentService
  def initialize(document_repository, listeners, document_id)
    @document_repository = document_repository
    @listeners = listeners
    @document_id = document_id
  end

  def call
    withdraw
    persist
    notify_listeners

    document
  end

private

  attr_reader :document_repository, :listeners, :document_id

  def withdraw
    document.withdraw!
  end

  def persist
    document_repository.store(document)
  end

  def notify_listeners
    listeners.each { |l| l.call(document) }
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end
end
