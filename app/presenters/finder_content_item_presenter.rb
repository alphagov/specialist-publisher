class FinderContentItemPresenter < Struct.new(:metadata, :schema, :timestamp)
  def exportable_attributes
    {
      "format" => format,
      "content_id" => content_id,
      "title" => title,
      "description" => description,
      "public_updated_at" => public_updated_at,
      "update_type" => update_type,
      "publishing_app" => publishing_app,
      "rendering_app" => rendering_app,
      "routes" => routes,
      "details" => details,
      "links" => {
        "organisations" => organisations,
        "related" => related,
        "email_alert_signup" => email_alert_signup,
      },
      "locale" => "en",
    }.merge(phase)
  end

  def base_path
    metadata.fetch("base_path")
  end

private
  def title
    metadata.fetch("name")
  end

  def content_id
    metadata.fetch("content_id")
  end

  def description
    metadata.fetch("description", "")
  end

  def details
    {
      beta_message: metadata.fetch("beta_message", nil),
      document_noun: schema.fetch("document_noun"),
      filter: metadata.fetch("filter", {}),
      format_name: metadata.fetch("format_name", nil),
      logo_path: metadata.fetch("logo_path", nil),
      signup_link: metadata.fetch("signup_link", nil),
      show_summaries: metadata.fetch("show_summaries", false),
      summary: metadata.fetch("summary", nil),
      facets: schema.fetch("facets", []),
      default_order: metadata.fetch("default_order", nil),
    }.reject {|_, value| value.nil?}
  end

  def format
    "finder"
  end

  def related
    metadata.fetch("related", [])
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

  def organisations
    metadata.fetch("organisations", [])
  end

  def update_type
    "minor"
  end

  def public_updated_at
    timestamp
  end

  def email_alert_signup
    [metadata.fetch("signup_content_id", nil)].compact
  end

  def phase
    phase = metadata["phase"]
    if phase
      {
        "phase" => phase
      }
    else
      {}
    end
  end
end
