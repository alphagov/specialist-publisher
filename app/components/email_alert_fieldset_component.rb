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

  # We are handling changes to email facet filters offline at present.
  def render_filtered_content_condition_inputs
    [
      render_hidden_signup_content_id_input("filtered_content_signup_id"),
      render_email_topic_list_title_prefix("filtered_content_list_title_prefix"),
      render_hidden_email_filter_options("filtered_content_email_filter_options"),
      render("govuk_publishing_components/components/checkboxes", {
        name: "email_filter_by",
        heading: "Selected filter: #{@email_alert.filter&.humanize}",
        no_hint_text: true,
        items: [
          {
            label: "Make changes to this filter criteria (The development team will reach out to you to discuss the requirements to allow users to sign up by specific filter criteria)",
            value: "CHANGE_REQUESTED",
          },
        ],
      }),
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
end
