require "fast_spec_helper"
require "email_alert_exporter"

RSpec.describe EmailAlertExporter do
  let(:delivery_api) { double(:delivery_api) }
  let(:formatter) {
    double(:formatter,
      identifier: "identifier",
      subject: "subject",
      body: "body",
    )
  }
  subject(:exporter) {
    EmailAlertExporter.new(
      delivery_api: delivery_api,
      formatter: formatter,
    )
  }

  before do
    allow(delivery_api).to receive(:notify)
  end

  it "notifies the delivery api with the formatter attributes" do
    exporter.call
    expect(delivery_api).to have_received(:notify)
      .with(
        "identifier",
        "subject",
        "body",
      )
  end
end
