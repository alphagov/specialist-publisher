require "fast_spec_helper"
require "publish_manual_service"
require "ostruct"
require "tag_fetcher"

RSpec.describe PublishManualService do

  let(:manual_id) { double(:manual_id) }
  let(:manual_repository) { double(:manual_repository) }
  let(:listeners) { [] }
  let(:manual) { double(:manual, id: manual_id, version_number: 3) }
  let(:tag_fetcher) { double(:tag_fetcher) }

  subject {
    PublishManualService.new(
      manual_id: manual_id,
      manual_repository: manual_repository,
      listeners: listeners,
      version_number: version_number,
    )
  }

  before do
    allow(manual_repository).to receive(:fetch) { manual }
    allow(manual_repository).to receive(:store)
    allow(manual).to receive(:publish)
    allow(manual).to receive(:update)
    allow(manual).to receive(:tags=)
    allow(tag_fetcher).to receive(:tags).and_return(
      [
        OpenStruct.new(
          details: OpenStruct.new(
            type: "specialist_sector",
          ),
          slug: "government-digital-guidance/content-publishing",
        )
      ]
    )
    allow(TagFetcher).to receive(:new).and_return(tag_fetcher)
  end

  context "when the version number is up to date" do
    let(:version_number) { 3 }

    it "publishes the manual" do
      subject.call
      expect(manual).to have_received(:publish)
    end

    it "updates the manuals tags" do
      subject.call
      expect(manual).to have_received(:update).with(
        {
          tags: [
            {
              type: "specialist_sector",
              slug: "government-digital-guidance/content-publishing",
            }
          ]
        }
      )
    end
  end

  context "when the version numbers differ" do
    let(:version_number) { 4 }

    it "should raise a PublishManualService::VersionMismatchError" do
      expect { subject.call }.to raise_error(PublishManualService::VersionMismatchError)
    end
  end
end
