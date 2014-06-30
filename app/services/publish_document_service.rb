class PublishDocumentService
  def initialize(document_repository, listeners, document_id)
    @document_repository = document_repository
    @listeners = listeners
    @document_id = document_id
  end

  def call
    publish
    persist

    document
  end

  private

  attr_reader :document_repository, :listeners, :document_id

  def publish
    document.publish!

    listeners.each { |o| o.call(document) }
  end

  def persist
    document_repository.store(document)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

  def document
    @document ||= document_repository.fetch(document_id)
  end
end
