class PublishDocumentService
  def initialize(document_repository, listeners, context)
    @document_repository = document_repository
    @listeners = listeners
    @context = context
    @document_previously_published = document.published?
  end

  def call
    publish
    persist

    document
  end

  private

  attr_reader :document_repository, :listeners, :context

  def publish
    document.publish!

    listeners.each { |o| o.call(document) }

    document.previous_editions.each(&:archive)
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

  def document_id
    context.params.fetch("id")
  end
end
