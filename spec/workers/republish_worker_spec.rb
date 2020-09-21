require "rails_helper"

RSpec.describe RepublishWorker do
  let(:content_id) { SecureRandom.uuid }
  let(:locale) { "en" }

  it "calls the RepublishService" do
    expect_any_instance_of(RepublishService)
      .to receive(:call).with(content_id, locale)

    described_class.perform_async(content_id, locale)
  end
end
