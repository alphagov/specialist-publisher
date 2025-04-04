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
      open_filter_on_load: file.fetch("open_filter_on_load", nil),
      logo_path: file.fetch("logo_path", nil),
      show_summaries: file.fetch("show_summaries", false),
      show_metadata_block: file.fetch("show_metadata_block", false),
      show_table_of_contents: file.fetch("show_table_of_contents", false),
      signup_link: file.fetch("signup_link", nil),
      summary:,
      label_text: file.fetch("label_text", nil),
      facets: FinderFacetPresenter.new(file.fetch("facets", nil)).to_json,
      default_order: file.fetch("default_order", nil),
      default_documents_per_page: 50,
    }.reject { |_, value| value.nil? }
  end

  def summary
    content = file.fetch("summary", nil)
    return nil if content.nil?

    [
      {
        content_type: "text/govspeak",
        content:,
      },
    ]
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
