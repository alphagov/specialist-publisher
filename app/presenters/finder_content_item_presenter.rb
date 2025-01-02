class FinderContentItemPresenter
  attr_reader :file, :timestamp

  def initialize(file, timestamp)
    @file = file
    @timestamp = timestamp
  end

  def to_json(*_args)
    {
      base_path:,
      document_type: format,
      schema_name: format,
      title:,
      description:,
      public_updated_at:,
      update_type:,
      publishing_app:,
      rendering_app:,
      routes:,
      details:,
      locale: "en",
    }.merge(phase)
  end

  def content_id
    file.fetch("content_id")
  end

  def self.facets_without_specialist_publisher_properties(facets)
    facets.reject { |facet| facet["specialist_publisher_properties"]&.fetch("omit_from_finder_content_item", false) }
          .map do |facet|
      facet.delete("specialist_publisher_properties")
      facet
    end
  end

private

  def title
    file.fetch("name")
  end

  def base_path
    file.fetch("base_path")
  end

  def description
    file.fetch("description", "")
  end

  def details
    {
      beta_message: file.fetch("beta_message", nil),
      document_noun: file.fetch("document_noun"),
      filter: file.fetch("filter", nil),
      format_name: file.fetch("format_name", nil),
      open_filter_on_load: file.fetch("open_filter_on_load", nil),
      logo_path: file.fetch("logo_path", nil),
      show_summaries: file.fetch("show_summaries", false),
      signup_link: file.fetch("signup_link", nil),
      summary: file.fetch("summary", nil),
      label_text: file.fetch("label_text", nil),
      facets: FinderContentItemPresenter.facets_without_specialist_publisher_properties(file.fetch("facets", nil)),
      default_order: file.fetch("default_order", nil),
      default_documents_per_page: 50,
    }.reject { |_, value| value.nil? }
  end

  def format
    "finder"
  end

  def routes
    [
      {
        path: base_path,
        type: "exact",
      },
      {
        path: "#{base_path}.json",
        type: "exact",
      },
      {
        path: "#{base_path}.atom",
        type: "exact",
      },
    ]
  end

  def publishing_app
    "specialist-publisher"
  end

  def rendering_app
    "finder-frontend"
  end

  def update_type
    "minor"
  end

  def public_updated_at
    timestamp.rfc3339
  end

  def phase
    phase = file["phase"]
    if phase
      {
        phase:,
      }
    else
      {}
    end
  end
end
