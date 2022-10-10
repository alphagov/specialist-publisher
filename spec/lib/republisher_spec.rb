require "rails_helper"

RSpec.describe Republisher do
  def stub_index(document_type, content_ids_and_locales:)
    stub_publishing_api_has_content(
      content_ids_and_locales.map { |c, l| { content_id: c, locale: l } },
      document_type:,
      fields: %i[content_id locale],
      per_page: 999_999,
      order: "updated_at",
    )
  end

  before do
    subject.document_types.each do |document_type|
      stub_index(document_type, content_ids_and_locales: [])
    end

    stub_index(
      "raib_report",
      content_ids_and_locales: [%w[raib-1 en], %w[raib-2 en]],
    )
    stub_index(
      "cma_case",
      content_ids_and_locales: [%w[cma-1 en], %w[cma-2 en]],
    )
  end

  describe ".republish_all" do
    it "enqueues a republish job for all documents" do
      expect(RepublishWorker).to receive(:perform_async).with("cma-1", "en")
      expect(RepublishWorker).to receive(:perform_async).with("cma-2", "en")
      expect(RepublishWorker).to receive(:perform_async).with("raib-1", "en")
      expect(RepublishWorker).to receive(:perform_async).with("raib-2", "en")

      subject.republish_all
    end
  end

  describe ".republish_document_type" do
    it "enqueues a republish job for all documents of the given type" do
      expect(RepublishWorker).to receive(:perform_async).with("cma-1", "en")
      expect(RepublishWorker).to receive(:perform_async).with("cma-2", "en")
      expect(RepublishWorker).not_to receive(:perform_async).with("raib-1", "en")

      subject.republish_document_type("cma_case")
    end

    it "raises an error if the document_type is unknown" do
      expect {
        subject.republish_document_type("unknown")
      }.to raise_error(/unknown document_type/i)
    end
  end

  describe ".republish_one" do
    it "immediately runs the job rather than enqueueing it" do
      expect(RepublishWorker).not_to receive(:perform_async)

      expect_any_instance_of(RepublishWorker).to receive(:perform).with("content-id", "en")
      expect_any_instance_of(RepublishWorker).not_to receive(:perform).with("raib-1", "en")

      subject.republish_one("content-id", "en")
    end
  end

  describe ".republish_many" do
    it "enqueues a republish job for the given content ids" do
      expect(RepublishWorker).to receive(:perform_async).with("content-id-1", "en")
      expect(RepublishWorker).to receive(:perform_async).with("content-id-2", "en")
      expect(RepublishWorker).not_to receive(:perform_async).with("raib-1", "en")

      subject.republish_many([%w[content-id-1 en], %w[content-id-2 en]])
    end
  end
end
