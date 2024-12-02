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

  it "sets the value of the radio button to 'all_content' if the schema has a signup content id" do
    schema = FinderSchema.new
    schema.signup_content_id = "123"
    render_inline(described_class.new(schema:))

    expect(page).to have_checked_field("email_alerts", with: "all_content")
  end
end
