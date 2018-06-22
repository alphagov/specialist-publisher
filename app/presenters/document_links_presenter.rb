class DocumentLinksPresenter
  BREXIT_CONTENT_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze

  def initialize(document)
    @document = document
  end

  def to_json
    json = {
      content_id: document.content_id,
      links: {
        organisations: document.schema_organisations,
        primary_publishing_organisation: [document.primary_publishing_organisation],
      },
    }
    if document.is_a? StatutoryInstrument
      json[:links][:taxons] = [BREXIT_CONTENT_ID]
    end
    json
  end

private

  attr_reader :document
end
