class FinderSignupContentItemPresenter < Struct.new(:metadata, :timestamp)
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
        "topics" => [],
        "related" => related,
      },
    }
  end

  def base_path
    "#{metadata.fetch("base_path")}/email-signup"
  end

private
  def title
    metadata.fetch("signup_title", metadata.fetch("name"))
  end

  def content_id
    metadata.fetch("signup_content_id")
  end

  def description
    metadata.fetch("signup_copy", nil)
  end

  def format
    "finder_email_signup"
  end

  def related
    [
      metadata.fetch("content_id"),
    ]
  end

  def routes
    [
      {
        path: base_path,
        type: "exact",
      }
    ]
  end

  def details
    {
      "beta" => metadata.fetch("signup_beta", false),
      "email_signup_choice" => metadata.fetch("email_signup_choice", []),
      "email_filter_by" => metadata.fetch("email_filter_by", nil),
      "subscription_list_title_prefix" => metadata.fetch("subscription_list_title_prefix", {})
    }
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
end
