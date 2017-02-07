require "rails_helper"

RSpec.describe RummagerBulkRepublisherWorker do
  around do |example|
    Sidekiq::Testing.fake! { example.run }
  end

  let(:cma_case) { FactoryGirl.create(:cma_case, :published) }
  let(:content_ids) { [cma_case["content_id"]] }

  it 'delegates a document to RummagerWorker' do
    publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    publishing_api_has_item(cma_case)

    payload = SearchPresenter.new(
      Document.find(cma_case["content_id"])
    ).to_json

    allow(RummagerWorker).to receive(:perform_async).with(
      cma_case["document_type"],
      cma_case["base_path"],
      payload
    )

    described_class.perform_async(CmaCase.document_type, 1, 1)

    expect(described_class.jobs.size).to eq(1)
    described_class.drain
    expect(described_class.jobs.size).to eq(0)
  end

  it 'publishes to rummager' do
    publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    publishing_api_has_item(cma_case)
    stub_any_rummager_post

    described_class.perform_async(CmaCase.document_type, 1, 1)
    described_class.drain
    RummagerWorker.drain

    assert_rummager_posted_item(
      _type: CmaCase.document_type,
      _id: cma_case["base_path"]
    )
  end
end
