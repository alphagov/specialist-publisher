class EmailAlertFieldsetComponent < ViewComponent::Base
  def initialize(schema:)
    @schema = schema
  end

  def render_all_content_condition_inputs
    signup_content_id_input = render("govuk_publishing_components/components/input", {
      type: "hidden",
      name: "signup_content_id",
      value: @schema.signup_content_id || SecureRandom.uuid,
    })

    # Do not render the title prefix input if the value is a hash because we don't want to override the existing the existing
    # values in such cases. We are going to revisit this later, but for now we only allow users to override this setting
    # for finders with a single string value.
    if @schema.subscription_list_title_prefix.is_a?(Hash)
      signup_content_id_input
    else
      render("govuk_publishing_components/components/input", {
        label: {
          text: "Email subscription topic",
        },
        name: "subscription_list_title_prefix",
        value: @schema.subscription_list_title_prefix,
      }) + signup_content_id_input
    end
  end

  # We are handling changes to email facet filters offline at present.
  def render_filtered_content_condition_inputs
    render("govuk_publishing_components/components/input", {
      type: "hidden",
      name: "signup_content_id",
      value: @schema.signup_content_id || SecureRandom.uuid,
    }) +
      render("govuk_publishing_components/components/checkboxes", {
        name: "email_filter_by",
        heading: "Selected filter: #{@schema.email_filter_by&.humanize}",
        items: [
          {
            label: "Make changes to this filter criteria (The development team will reach out to you to discuss the requirements to allow users to sign up by specific filter criteria)",
            value: "CHANGE_REQUESTED",
          },
        ],
      })
  end

  def render_external_condition_inputs
    render("govuk_publishing_components/components/input", {
      label: {
        text: "Signup link",
      },
      hint: "A link to an email signup page",
      name: "signup_link",
      value: @schema.signup_link,
    })
  end
end
