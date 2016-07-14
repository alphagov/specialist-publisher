FinderContentItemPresenter = Struct.new(:file, :timestamp) do
  def to_json
    {
      base_path: base_path,
      document_type: format,
      schema_name: format,
      content_id: content_id,
      title: title,
      description: description,
      public_updated_at: public_updated_at,
      update_type: update_type,
      publishing_app: publishing_app,
      rendering_app: rendering_app,
      routes: routes,
      details: details,
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
      format_name: file.fetch("format_name", nil),
      logo_path: file.fetch("logo_path", nil),
      signup_link: file.fetch("signup_link", nil),
      show_summaries: file.fetch("show_summaries", false),
      summary: file.fetch("summary", nil),
      facets: file.fetch("facets", nil),
      default_order: file.fetch("default_order", nil),
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
      }
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
    timestamp
  end

  def phase
    phase = file["phase"]
    if phase
      {
        phase: phase
      }
    else
      {}
    end
  end
end
