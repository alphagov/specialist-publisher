require "rails_helper"

RSpec.describe EmailAlertFieldsetComponent, type: :component do
  it "renders an email alerts fieldset containing two radio buttons with expected values" do
    schema = EmailAlert.new
    render_inline(described_class.new(schema:))
    expect(page).to have_text("Email Alerts")
    expect(page).to have_field("email_alerts_enabled")
  end

  it "sets the value of the radio button to 'no' if the schema does not have email alerts enabled" do
    schema = EmailAlert.new
    schema.enabled = :no
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts_enabled", with: "no")
  end

  it "sets the value of the radio button to 'all_content' if the schema has a signup content id and renders conditional fields" do
    schema = EmailAlert.new
    schema.enabled = :all_content
    schema.content_id = "123"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts_enabled", with: "all_content")
    expect(page).to have_field("all_content_signup_id", with: "123", type: "hidden")
  end

  it "sets the value of the radio button to 'all_content' and renders a hidden input with a generated content id if the schema is missing a signup content id" do
    schema = EmailAlert.new
    schema.enabled = :all_content
    allow(SecureRandom).to receive(:uuid).and_return("new-id")
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts_enabled", with: "all_content")
    expect(page).to have_field("all_content_signup_id", with: "new-id", type: "hidden")
  end

  it "renders the email subscription topic if the all_content value is checked" do
    schema = EmailAlert.new
    schema.enabled = :all_content
    schema.list_title_prefix = "Finder email subscription"
    render_inline(described_class.new(schema:))

    expect(page).to have_text("Email subscription topic")
    expect(page).to have_field("all_content_list_title_prefix", with: schema.list_title_prefix)
  end

  # We do not render the title prefix input if the value is a hash because we don't want to override the existing the existing
  # values in such cases. We are going to revisit this later. Trello card for future work: https://trello.com/c/Qe8wOpaw
  it "does not render the email subscription topic if the all_content value is checked but the current schema value is a hash" do
    schema = EmailAlert.new
    schema.enabled = :all_content
    schema.list_title_prefix = {}
    render_inline(described_class.new(schema:))

    expect(page).not_to have_text("Email subscription topic")
    expect(page).not_to have_field("all_content_list_title_prefix", with: schema.list_title_prefix)
  end

  it "sets the value of the radio button to 'external' if email alerts are enabled using an external system" do
    schema = EmailAlert.new
    schema.enabled = :external
    schema.link = "https://example.com"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts_enabled", with: "external")
    expect(page).to have_field("signup_link", with: schema.link)
  end

  it "sets the value of the radio button to 'filtered_content' if email alerts are enabled for a filtered subset of the content" do
    schema = EmailAlert.new
    schema.enabled = :filtered_content
    schema.content_id = "123"
    schema.filter = "some_facet"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts_enabled", with: "filtered_content")
    expect(page).to have_text("Selected filter: Some facet")
    expect(page).to have_field("filtered_content_signup_id", with: schema.content_id, type: "hidden")
    expect(page).to have_unchecked_field("email_filter_by", with: "CHANGE_REQUESTED")
  end

  it "sets the value of the radio button to 'filtered_content' and renders a hidden input with a generated content id if the schema is missing a signup content id" do
    schema = EmailAlert.new
    schema.enabled = :filtered_content
    schema.filter = "some_facet"
    allow(SecureRandom).to receive(:uuid).and_return("new-id")
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts_enabled", with: "filtered_content")
    expect(page).to have_field("filtered_content_signup_id", with: "new-id", type: "hidden")
  end
end
