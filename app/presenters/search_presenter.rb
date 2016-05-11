class SearchPresenter
  delegate :title, to: :document

  def initialize(document)
    @document = document
  end

  def to_json
    {
      title: document.title,
      description: document.summary,
      link: document.base_path,
      indexable_content: indexable_content,
      organisations: organisation_slugs,
      public_timestamp: document.public_updated_at.to_datetime.rfc3339,
    }.merge(document.format_specific_metadata).reject { |_k, v| v.blank? }
  end

  def indexable_content
    document.body
  end

  def organisation_slugs
    response = publishing_api.get_linkables(document_type: "organisation")

    organisations = response.select do |organisation|
      document.organisations.include?(organisation["content_id"])
    end

    organisations.map do |org|
      org["base_path"].gsub("/government/organisations/", "").gsub("/courts-tribunals/", "")
    end
  end

private

  attr_reader :document

  def publishing_api
    @publishing_api ||= Services.publishing_api
  end
end
