class UpdateDocumentService
  def initialize(options)
    @repo = options.fetch(:repo)
    @listeners = options.fetch(:listeners)
    @document_id = options.fetch(:document_id)
    @attributes = options.fetch(:attributes)
  end

  def call
    document.update(attributes)
    if !document.minor_update
      document.change_history << {
        public_timestamp: Time.now,
        note: document.change_note
      }
    end

    if document.valid?
      persist
      notify_listeners
    end

    document
  end

  private

  attr_reader :repo, :listeners, :attributes, :document_id

  def persist
    repo.store(document)
  end

  def notify_listeners
    listeners.each do |listener|
      listener.call(document)
    end
  end

  def document
    @document ||= repo.fetch(document_id)
  end
end
