require "rails_helper"

RSpec.describe EmailAlertFieldsetComponent, type: :component do
  it "renders an email alerts fieldset containing two radio buttons with expected values" do
    email_alert = EmailAlert.new
    render_inline(described_class.new(email_alert:))
    expect(page).to have_text("Email Alerts")
    expect(page).to have_field("email_alert_type")
  end

  it "sets the value of the radio button to 'no' if the email alert is not enabled" do
    email_alert = EmailAlert.new
    email_alert.type = :no
    render_inline(described_class.new(email_alert:))

    expect(page).to have_checked_field("email_alert_type", with: "no")
  end

  it "sets the value of the radio button to 'all_content' if the email alert is enabled for all content" do
    email_alert = EmailAlert.new
    email_alert.type = :all_content
    email_alert.content_id = "123"
    render_inline(described_class.new(email_alert:))

    expect(page).to have_checked_field("email_alert_type", with: "all_content")
    expect(page).to have_field("all_content_signup_id", with: "123", type: "hidden")
  end

  it "sets the value of the radio button to 'all_content' and renders a hidden input with a generated content id if the alert is missing a signup content id" do
    email_alert = EmailAlert.new
    email_alert.type = :all_content
    allow(SecureRandom).to receive(:uuid).and_return("new-id")
    render_inline(described_class.new(email_alert:))

    expect(page).to have_checked_field("email_alert_type", with: "all_content")
    expect(page).to have_field("all_content_signup_id", with: "new-id", type: "hidden")
  end

  it "renders the email subscription topic if the all_content value is checked" do
    email_alert = EmailAlert.new
    email_alert.type = :all_content
    email_alert.list_title_prefix = "Finder email subscription"
    render_inline(described_class.new(email_alert:))

    expect(page).to have_text("Email subscription topic")
    expect(page).to have_field("all_content_list_title_prefix", with: email_alert.list_title_prefix)
  end

  # We do not render the title prefix input if the value is a hash because we don't want to override the existing the existing
  # values in such cases. We are going to revisit this later. Trello card for future work: https://trello.com/c/Qe8wOpaw
  it "does not render the email subscription topic if the all_content value is checked but the current topic value is a hash" do
    email_alert = EmailAlert.new
    email_alert.type = :all_content
    email_alert.list_title_prefix = {}
    render_inline(described_class.new(email_alert:))

    expect(page).not_to have_text("Email subscription topic")
    expect(page).not_to have_field("all_content_list_title_prefix", with: email_alert.list_title_prefix)
  end

  it "sets the value of the radio button to 'external' if email alerts are enabled using an external system" do
    email_alert = EmailAlert.new
    email_alert.type = :external
    email_alert.link = "https://example.com"
    render_inline(described_class.new(email_alert:))

    expect(page).to have_checked_field("email_alert_type", with: "external")
    expect(page).to have_field("signup_link", with: email_alert.link)
  end

  it "sets the value of the radio button to 'filtered_content' if email alerts are enabled for a filtered subset of the content" do
    email_alert = EmailAlert.new
    email_alert.type = :filtered_content
    email_alert.content_id = "123"
    email_alert.filter = "some_facet"
    render_inline(described_class.new(email_alert:))

    expect(page).to have_checked_field("email_alert_type", with: "filtered_content")
    expect(page).to have_text("Selected filter: Some facet")
    expect(page).to have_field("filtered_content_signup_id", with: email_alert.content_id, type: "hidden")
    expect(page).to have_unchecked_field("email_filter_by", with: "CHANGE_REQUESTED")
  end

  it "sets the value of the radio button to 'filtered_content' and renders a hidden input with a generated content id if the alert is missing a signup content id" do
    email_alert = EmailAlert.new
    email_alert.type = :filtered_content
    email_alert.filter = "some_facet"
    allow(SecureRandom).to receive(:uuid).and_return("new-id")
    render_inline(described_class.new(email_alert:))

    expect(page).to have_checked_field("email_alert_type", with: "filtered_content")
    expect(page).to have_field("filtered_content_signup_id", with: "new-id", type: "hidden")
  end
end
