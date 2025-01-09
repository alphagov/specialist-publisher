class FinderSignupContentItemPresenter
  attr_reader :schema, :timestamp

  def initialize(schema, timestamp = Time.zone.now)
    @schema = schema
    @timestamp = timestamp
  end

  def to_json(*_args)
    {
      base_path:,
      title:,
      schema_name:,
      document_type:,
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
    email_filter_options.fetch("signup_content_id")
  end

  def email_filter_facets
    return [] if email_filter_by.nil?

    map_facets_to_email_facets(select_relevant_facets)
  end

  def subscription_list_title_prefix
    email_filter_options.fetch("subscription_list_title_prefix", {})
  end

private

  def email_filter_by
    email_filter_options.fetch("email_filter_by", nil)
  end

  def email_filter_options
    schema.fetch("email_filter_options", {})
  end

  def select_relevant_facets
    facets = schema.fetch("facets", [])
    if email_filter_by == "all_selected_facets"
      facets.select do |facet|
        facet["filterable"] &&
          facet["allowed_values"] &&
          !(email_filter_options["all_selected_facets_except_for"] || []).include?(facet["key"])
      end
    else
      facets.select { |facet| facet.fetch("key") == email_filter_by }
    end
  end

  def map_facets_to_email_facets(facets)
    facets.map do |facet|
      {
        facet_id: facet["key"],
        facet_name: facet["name"],
        required: email_filter_by == "all_selected_facets" ? nil : true,
        facet_choices: facet["allowed_values"].map do |allowed_value|
          topic_name = if (overridden_topic_name = email_filter_options["email_alert_topic_name_overrides"]&.fetch(allowed_value["value"], nil))
                         overridden_topic_name
                       elsif email_filter_options["downcase_email_alert_topic_names"]
                         allowed_value["label"].downcase
                       else
                         allowed_value["label"]
                       end

          {
            key: allowed_value["value"],
            radio_button_name: allowed_value["label"],
            topic_name:,
            prechecked: (email_filter_options["pre_checked_email_alert_checkboxes"] || []).include?(allowed_value["value"]),
          }
        end,
      }.compact
    end
  end

  def locale
    "en"
  end

  def title
    schema.fetch("name")
  end

  def base_path
    "#{schema.fetch('base_path')}/email-signup"
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
      "email_filter_facets" => email_filter_facets,
      "email_filter_by" => email_filter_by,
      "filter" => schema.fetch("filter", nil),
      "subscription_list_title_prefix" => subscription_list_title_prefix,
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
