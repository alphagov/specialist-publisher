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
    }.merge(document.format_specific_metadata).reject { |k, v| v.blank? }
  end

  def indexable_content
    document.body
  end

  def organisation_slugs
    response = publishing_api.get_content_items({content_format: "organisation", fields: [:content_id, :base_path]})

    orgs = response.select { |o| document.organisations.include?(o["content_id"]) }
    orgs.map { |o| o["base_path"].gsub("/government/organisations/", "")}.map { |o| o.gsub("/courts-tribunals/", "") }
  end

private

  attr_reader :document

  def publishing_api
    @publishing_api ||= SpecialistPublisher.services(:publishing_api)
  end

end
