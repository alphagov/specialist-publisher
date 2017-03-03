class DocumentLinksPresenter
  def initialize(document)
    @document = document
  end

  def to_json
    {
      content_id: document.content_id,
      links: {
        organisations: document.organisations,
        parent: [parent_content_id]
      },
    }
  end

private

  attr_reader :document

  def parent_content_id
    document.finder_schema.content_id
  end
end
