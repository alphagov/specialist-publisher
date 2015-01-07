require "time"

class FinderContentItemPresenter < Struct.new(:metadata, :schema)
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

  def rendering_app
    "finder-frontend"
  end

  def organisations
    metadata.fetch("organisations", [])
  end

  def update_type
    "minor"
  end
end
