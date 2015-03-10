class CmaImportMissingBodyGenerator
  def initialize(create_document_service:, document_repository:)
    @create_document_service = create_document_service
    @document_repository = document_repository
  end

  def call(data)
    document = create_document_service.call(data)

    if needs_body_generating?(document)
      generate_body(document)

      document_repository.store(document)

      Presenter.new(document)
    else
      document
    end
  end

private
  attr_reader :create_document_service, :document_repository

  def needs_body_generating?(document)
    document.body.empty? && document.attachments.size == 1
  end

  def default_body
    "Full text of the decision"
  end

  def generate_body(document)
    attachment = document.attachments.first.snippet
    document.update(body: "#{default_body} #{attachment}")
  end

  class Presenter < SimpleDelegator
    def import_notes
      super.concat(messages)
    end

  private
    def messages
      [
        body_missing_message,
      ]
    end

    def body_missing_message
      "missing `body` field replaced with default"
    end
  end
end
