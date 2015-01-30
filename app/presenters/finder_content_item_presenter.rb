class FinderContentItemPresenter < Struct.new(:metadata, :schema, :timestamp)
  def exportable_attributes
    {
      "base_path" => base_path,
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
        "topics" => [],
        "related" => related,
        "email_alert_signup" => email_alert_signup,
      },
    }
  end

private
  def title
    metadata.fetch("name")
  end

  def content_id
    metadata.fetch("content_id")
  end

  def base_path
    "/#{metadata.fetch("slug", "")}"
  end

  def description
    ""
  end

  def details
    {
      beta: metadata.fetch("beta", false),
      beta_message: metadata.fetch("beta_message", nil),
      document_noun: schema.fetch("document_noun"),
      document_type: metadata.fetch("format"),
      email_signup_enabled: metadata.fetch("signup_enabled", false),
      format_name: metadata.fetch("format_name"),
      signup_link: metadata.fetch("signup_link", nil),
      show_summaries: metadata.fetch("show_summaries", false),
      facets: schema.fetch("facets"),
    }
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
      }
    ]
  end

  def need_ids
    []
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
end
