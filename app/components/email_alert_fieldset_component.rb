class EmailAlertFieldsetComponent < ViewComponent::Base
  def initialize(email_alert:)
    @email_alert = email_alert
  end

  def render_all_content_condition_inputs
    [
      render_hidden_signup_content_id_input("all_content_signup_id"),
      render_email_topic_list_title_prefix("all_content_list_title_prefix"),
      render_hidden_email_filter_options("all_content_email_filter_options"),
    ].compact.join.html_safe
  end

  def render_filtered_content_condition_inputs
    [
      render_hidden_signup_content_id_input("filtered_content_signup_id"),
      render_email_topic_list_title_prefix("filtered_content_list_title_prefix"),
      render_hidden_email_filter_options("filtered_content_email_filter_options"),
      render_email_filter_by_select("email_filter_by"),
    ].compact.join.html_safe
  end

  def render_external_condition_inputs
    render("govuk_publishing_components/components/input", {
      label: {
        text: "Signup link",
      },
      hint: "A link to an email signup page",
      name: "signup_link",
      value: @email_alert.link,
    })
  end

private

  def render_email_topic_list_title_prefix(input_name)
    render("govuk_publishing_components/components/input", {
      label: {
        text: "Email subscription topic",
      },
      name: input_name,
      value: @email_alert.list_title_prefix,
      hint: "This reminds subscribers of the topic of the finder when they are sent emails or they are managing their subscriptions. Example: 'Funding for land or farms'",
    })
  end

  def render_hidden_signup_content_id_input(input_name)
    render("govuk_publishing_components/components/input", {
      type: "hidden",
      name: input_name,
      value: @email_alert.content_id || SecureRandom.uuid,
    })
  end

  def render_hidden_email_filter_options(input_name)
    render("govuk_publishing_components/components/input", {
      type: "hidden",
      name: input_name,
      value: @email_alert.email_filter_options.to_json,
    })
  end

  def render_email_filter_by_select(input_name)
    render("govuk_publishing_components/components/select", {
      id: input_name,
      name: input_name,
      label: "Email filter",
      hint: "'all_selected_facets' subscribes users to whatever facets they chose on the search page (there is no option to edit their choices on the email signup page). For any other option, users can edit their choices on the email signup page, and any facets chosen on the search page are prefilled.",
      options: (@email_alert.email_filter_by_candidates || []).map do |facet|
        {
          text: facet,
          value: facet,
          selected: @email_alert.filter == facet,
        }
      end,
    })
  end
end
