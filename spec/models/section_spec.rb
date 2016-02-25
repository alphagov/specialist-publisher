require "spec_helper"
require "manual"

RSpec.describe Section do
  let(:content_id) { SecureRandom.uuid }

  describe ".find" do
    let(:manual_content_id) { SecureRandom.uuid }
    let(:section) do
      described_class.new(content_id: content_id,
                          manual_content_id: manual_content_id)
    end

    before do
      expect(described_class).to receive(:from_publishing_api)
        .with(content_id: content_id)
        .and_return(section)
    end

    context "with content_id" do
      it "fetches the content item from the publishing api" do
        expect(described_class.find(content_id: content_id)).to eq(section)
      end
    end

    context "with content_id and manual_content_id" do
      it "fetches the content item and validates it belongs to the specified manual" do
        result = described_class.find(content_id: content_id, manual_content_id: manual_content_id)
        expect(result).to eq(section)
      end
    end

    context "with an invalid manual_content_id" do
      it "raises a InvalidManual error" do
        expect {
          described_class.find(content_id: content_id, manual_content_id: SecureRandom.uuid)
        }.to raise_error(Section::RecordNotFound)
      end
    end
  end

  describe ".from_publishing_api" do
    let(:manual_content_id) { SecureRandom.uuid }
    let(:content_item) do
      {
        content_id: content_id,
        title: "Section title",
        description: "Section description",
        details: { body: "## Some body text" },
      }
    end

    context "given a section exists" do

      before do
        publishing_api_has_item(content_item)
        publishing_api_has_links({ content_id: content_id, links: { manual: [manual_content_id] } })
      end

      subject { described_class.from_publishing_api(content_id: content_id) }

      it "retrieves a content item from the publishing api get_content endpoint by content_id" do
        expect(subject).to be_a(Section)

        assert_publishing_api(:get, "#{Plek.current.find('publishing-api')}/v2/content/#{content_id}")

        expect(subject.content_id).to eq(content_id)
        expect(subject.title).to eq("Section title")
        expect(subject.summary).to eq("Section description")
        expect(subject.body).to eq("## Some body text")
        expect(subject.manual_content_id).to eq(manual_content_id)
      end
    end

    context "when a section doesn't exist for content_id" do
      before do
        publishing_api_does_not_have_item(content_id)
      end

      it "raises an appropriate error" do
        expect {
          described_class.from_publishing_api(content_id: content_id)
        }.to raise_error(Section::RecordNotFound)
      end
    end
  end
end
