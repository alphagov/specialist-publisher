class ShowDocumentService

  def initialize(document_repository, document_id)
    @document_repository = document_repository
    @document_id = document_id
  end

  def call
    [document, other_metadata]
  end

private

  attr_reader :document_repository, :document_id

  def document
    @document ||= document_repository.fetch(document_id)
  end

  def other_metadata
    {
      slug_unique: slug_unique?,
      publishable: publishable?,
    }
  end

  def slug_unique?
    document_repository.slug_unique?(document)
  end

  def publishable?
    document.latest_edition != document.published_edition
  end
end
