require "time"

class FinderContentItemPresenter < Struct.new(:metadata, :schema)
  def title
    metadata["name"]
  end

  def content_id
    metadata["content_id"]
  end

  def base_path
    "/#{metadata["slug"]}"
  end

  def description
    ""
  end

  def details
    {
      beta: metadata.fetch("beta", false),
      beta_message: metadata.fetch("beta_message", nil),
      document_noun: schema["document_noun"],
      document_type: metadata["format"],
      email_signup_enabled: metadata.fetch("signup_enabled", false),
      facets: schema["facets"],
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
    metadata["organisations"]
  end

  def update_type
    "minor"
  end
end
