class PublishDocumentService
  def initialize(document_repository, listeners, document)
    @document_repository = document_repository
    @listeners = listeners
    @document = document
    @document_previously_published = document.published?
  end

  def call
    publish
    persist

    document
  end

  private

  attr_reader :document_repository, :listeners, :document

  def publish
    document.publish!

    listeners.each { |o| o.call(document) }

    document.previous_editions.each(&:archive)
  end

  def persist
    document_repository.store!(document)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

end
