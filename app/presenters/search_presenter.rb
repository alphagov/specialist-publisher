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
      # FIXME: This line was dependent on a method called #organisation_slugs,
      # which in turn used publishing_api.get_content to map org content_ids to
      # organisation slugs. It was stubbed in many places in spec/, but that method
      # call always returned a blank list in the real world.
      organisations: [],
      public_timestamp: document.public_updated_at.to_datetime.rfc3339,
    }.merge(document.format_specific_metadata).reject { |_k, v| v.blank? }
  end

  def indexable_content
    document.body
  end

private

  attr_reader :document

  def publishing_api
    @publishing_api ||= Services.publishing_api
  end
end
