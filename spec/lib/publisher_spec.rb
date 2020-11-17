require "rails_helper"

RSpec.describe Publisher do
  before do
    expect_any_instance_of(described_class).to receive(:document_types).and_return(%w[raib_report some_class])

    stub_publishing_api_has_content(
      [
        { content_id: "raib-1", locale: "en" },
        { content_id: "raib-2", locale: "en" },
      ],
      document_type: "raib_report",
      publication_state: "draft",
      fields: %i[content_id locale],
      per_page: 999_999,
      order: "updated_at",
    )
  end

  describe ".publish_all" do
    it "find all documents in the domain still in a draft state and triggers the publishing operation on them" do
      document_raib1 = double(:document_raib1)
      document_raib2 = double(:document_raib2)

      expect(Document).to receive(:find).with("raib-1", "en").and_return(document_raib1)
      expect(Document).to receive(:find).with("raib-2", "en").and_return(document_raib2)
      expect(document_raib1).to receive(:publish)
      expect(document_raib2).to receive(:publish)

      described_class.publish_all(types: %w[raib_report])
    end

    context "when the types is not known" do
      it "fails and report an error" do
        expect { described_class.publish_all(types: %w[some_type]) }.to raise_error(ArgumentError)
      end
    end
  end
end
