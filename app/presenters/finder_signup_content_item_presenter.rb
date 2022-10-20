class FinderSignupContentItemPresenter
  attr_reader :schema, :timestamp

  def initialize(schema, timestamp)
    @schema = schema
    @timestamp = timestamp
  end

  def to_json(*_args)
    {
      base_path:,
      title:,
      schema_name:,
      document_type:,
      description:,
      public_updated_at:,
      update_type:,
      publishing_app:,
      rendering_app:,
      routes:,
      details:,
      locale:,
    }
  end

  def content_id
    schema.fetch("signup_content_id")
  end

private

  def locale
    "en"
  end

  def title
    schema.fetch("signup_title", schema.fetch("name"))
  end

  def base_path
    "#{schema.fetch('base_path')}/email-signup"
  end

  def description
    schema.fetch("signup_copy", nil)
  end

  def document_type
    "finder_email_signup"
  end

  def schema_name
    "finder_email_signup"
  end

  def related
    [
      schema.fetch("content_id"),
    ]
  end

  def routes
    [
      {
        path: base_path,
        type: "exact",
      },
    ]
  end

  def details
    {
      "beta" => schema.fetch("signup_beta", false),
      "email_filter_facets" => schema.fetch("email_filter_facets", []),
      # TODO: Remove email_filter_by once finder-frontend doesn't use it.
      "email_filter_by" => schema.fetch("email_filter_by", nil),
      "filter" => schema.fetch("filter", nil),
      "subscription_list_title_prefix" => schema.fetch("subscription_list_title_prefix", {}),
    }
  end

  def publishing_app
    "specialist-publisher"
  end

  def rendering_app
    "finder-frontend"
  end

  def organisations
    schema.fetch("organisations", [])
  end

  def update_type
    "minor"
  end

  def public_updated_at
    timestamp.in_time_zone.rfc3339
  end
end
