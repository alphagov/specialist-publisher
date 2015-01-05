require "time"

class FinderSignupContentItemPresenter < Struct.new(:metadata)
  def title
    metadata.fetch("signup_title", metadata["name"])
  end

  def content_id
    metadata["signup_content_id"]
  end

  def base_path
    "/#{metadata["slug"]}/email-signup"
  end

  def description
    metadata["signup_copy"]
  end

  def format
    "finder_email_signup"
  end

  def related
    [metadata["content_id"]]
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
