class DocumentLinksPresenter
  def initialize(document)
    @document = document
  end

  def to_json
    {
      content_id: document.content_id,
      links: {
        organisations: document.organisations,
        primary_publishing_organisation: [document.primary_publishing_organisation],
      },
    }
  end

private

  attr_reader :document
end
