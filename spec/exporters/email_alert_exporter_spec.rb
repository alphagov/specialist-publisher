require "fast_spec_helper"
require "email_alert_exporter"

RSpec.describe EmailAlertExporter do
  let(:email_alert_api) { double(:email_alert_api) }
  let(:email_subject) { double(:email_subject) }
  let(:email_body) { double(:email_body) }
  let(:email_tags) { double(:email_tags) }
  let(:formatter) {
    double(:formatter,
      name: "format name",
      subject: email_subject,
      body: email_body,
      tags: email_tags,
      extra_options: {},
    )
  }
  subject(:exporter) {
    EmailAlertExporter.new(
      email_alert_api: email_alert_api,
      formatter: formatter,
    )
  }

  before do
    allow(email_alert_api).to receive(:send_alert)
  end

  it "notifies the email alert api with the formatter attributes" do
    exporter.call
    expect(email_alert_api).to have_received(:send_alert)
      .with(
        "subject" => email_subject,
        "body" => email_body,
        "tags" => email_tags,
      )
  end

  it "includes extra options if they are specified" do
    extra_options = {
      urgent: true,
      email_address_id: 12345,
      header: "foo",
      footer: "bar",
    }
    allow(formatter).to receive(:extra_options).and_return(extra_options)
    exporter.call
    expect(email_alert_api).to have_received(:send_alert).with(hash_including(extra_options))
  end
end
