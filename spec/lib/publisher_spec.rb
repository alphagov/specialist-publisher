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
    stub_publishing_api_has_item(stub_content_item("raib-1"))
    stub_publishing_api_has_item(stub_content_item("raib-2"))
  end

  def stub_content_item(content_id)
    {
      content_id:,
      title: "some title",
      locale: "en",
      document_type: "raib_report",
      publication_state: "draft",
      state_history: [],
      details: {
        body: "<p>body 3</p>",
        metadata: {},
      },
    }
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

    it "sends email alerts when publishing documents by default" do
      expect(Services.publishing_api).to receive(:publish).twice
      expect(EmailAlertApiWorker).to receive(:perform_async).twice

      described_class.publish_all(types: %w[raib_report])
    end

    it "does not send email alerts when publishing documents if passed disable_email_alert flag" do
      expect(Services.publishing_api).to receive(:publish).twice
      expect(EmailAlertApiWorker).to_not receive(:perform_async)

      described_class.publish_all(types: %w[raib_report], disable_email_alert: true)
    end

    context "when the types is not known" do
      it "fails and report an error" do
        expect { described_class.publish_all(types: %w[some_type]) }.to raise_error(ArgumentError)
      end
    end
  end
end
