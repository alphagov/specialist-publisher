class RepublishDocumentService
  def initialize(document_repository:, listeners: [], document_id:)
    @document_repository = document_repository
    @listeners = listeners
    @document_id = document_id
  end

  def call
    if document.published?
      notify_listeners
    end

    document
  end

private
  attr_reader :document_repository, :listeners, :document_id

  def notify_listeners
    listeners.each { |l| l.call(document) }
  end

  def document
    @document ||= document_repository.fetch(document_id)
  rescue KeyError => error
    raise DocumentNotFoundError.new(error)
  end

  class DocumentNotFoundError < StandardError; end
end
