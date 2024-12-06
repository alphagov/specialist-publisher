require "rails_helper"

RSpec.describe EmailAlertFieldsetComponent, type: :component do
  it "renders an email alerts fieldset containing two radio buttons with expected values" do
    schema = FinderSchema.new
    render_inline(described_class.new(schema:))
    expect(page).to have_text("Email Alerts")
    expect(page).to have_field("email_alerts")
  end

  it "sets the value of the radio button to 'no' if the schema does not have a signup_content_id" do
    schema = FinderSchema.new
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "no")
  end

  it "sets the value of the radio button to 'no' if the schema does not have a signup_content_id" do
    schema = FinderSchema.new
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "no")
  end

  it "sets the value of the radio button to 'all_content' if the schema has a signup content id" do
    schema = FinderSchema.new
    schema.signup_content_id = "123"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "all_content")
    expect(page).to have_field("signup_content_id", with: "123", type: "hidden")
  end

  it "sets the value of the radio button to 'all_content' and renders a hidden input with a generated content id if the schema is missing a signup content id" do
    schema = FinderSchema.new
    allow(SecureRandom).to receive(:uuid).and_return("new-id")
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "no")
    expect(page).to have_field("signup_content_id", with: "new-id", type: "hidden")
  end

  it "renders the email subscription topic if the all_content value is checked" do
    schema = FinderSchema.new
    schema.signup_content_id = "123"
    schema.subscription_list_title_prefix = "Finder email subscription"
    render_inline(described_class.new(schema:))

    expect(page).to have_text("Email subscription topic")
    expect(page).to have_field("subscription_list_title_prefix", with: schema.subscription_list_title_prefix)
  end

  # We do not render the title prefix input if the value is a hash because we don't want to override the existing the existing
  # values in such cases. We are going to revisit this later. Trello card for future work: https://trello.com/c/Qe8wOpaw
  it "does not render the email subscription topic if the all_content value is checked but the current schema value is a hash" do
    schema = FinderSchema.new
    schema.signup_content_id = "123"
    schema.subscription_list_title_prefix = {}
    render_inline(described_class.new(schema:))

    expect(page).not_to have_text("Email subscription topic")
    expect(page).not_to have_field("subscription_list_title_prefix", with: schema.subscription_list_title_prefix)
  end

  it "sets the value of the radio button to 'external' if the schema has a signup link" do
    schema = FinderSchema.new
    schema.signup_link = "https://example.com"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "external")
    expect(page).to have_field("signup_link", with: schema.signup_link)
  end

  it "sets the value of the radio button to 'filtered_content' if the schema has an email filter attribute" do
    schema = FinderSchema.new
    schema.signup_content_id = "123"
    schema.email_filter_by = "some_facet"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "filtered_content")
    expect(page).to have_text("Selected filter: Some facet")
    expect(page).to have_field("signup_content_id", with: schema.signup_content_id, type: "hidden")
    expect(page).to have_unchecked_field("email_filter_by", with: "CHANGE_REQUESTED")
  end
end
