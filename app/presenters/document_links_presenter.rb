class DocumentLinksPresenter
  def initialize(document)
    @document = document
  end

  def to_json
    {
      content_id: document.content_id,
      links: {
        organisations: document.organisations
      },
    }
    end

private

  attr_reader :document
end
