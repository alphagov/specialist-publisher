require "rails_helper"

RSpec.describe RummagerWorker do
  include GdsApi::TestHelpers::Rummager

  before do
    stub_any_rummager_post
  end

  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  it "asynchronously posts an item to rummager" do
    described_class.perform_async(
      "document_type",
      "base_path",
      some: "payload",
    )

    expect(described_class.jobs.size).to eq(1)
    described_class.drain
    expect(described_class.jobs.size).to eq(0)

    assert_rummager_posted_item(
      _type: "document_type",
      _id: "base_path",
      some: "payload",
    )
  end
end
