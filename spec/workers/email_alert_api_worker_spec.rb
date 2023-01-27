require "rails_helper"

RSpec.describe EmailAlertApiWorker do
  include GdsApi::TestHelpers::EmailAlertApi

  before do
    stub_email_alert_api_accepts_content_change
  end

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  it "asynchronously sends a notification to email alert api" do
    described_class.perform_async("some" => "payload")

    expect(described_class.jobs.size).to eq(1)
    described_class.drain
    expect(described_class.jobs.size).to eq(0)

    assert_email_alert_api_content_change_created("some" => "payload")
  end

  it "doesn't retry 409s" do
    stub_any_email_alert_api_call.and_raise(GdsApi::HTTPConflict.new(409))

    expect(Sidekiq.logger).to receive(:info).with(/email-alert-api returned 409 conflict/)

    expect {
      described_class.new.perform(payload: {})
    }.not_to raise_error
  end
end
