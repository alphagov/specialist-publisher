require "rails_helper"

RSpec.describe Republisher do
  def stub_index(document_type, content_ids:)
    publishing_api_has_content(
      content_ids.map { |c| { content_id: c } },
      document_type: document_type,
      fields: [:content_id],
      per_page: 999999,
    )
  end

  before do
    subject.document_types.each do |document_type|
      stub_index(document_type, content_ids: [])
    end

    stub_index("raib_report", content_ids: ["raib-1", "raib-2"])
    stub_index("cma_case", content_ids: ["cma-1", "cma-2"])
  end

  describe ".republish_all" do
    it "enqueues a republish job for all documents" do
      expect(RepublishWorker).to receive(:perform_async).with("cma-1")
      expect(RepublishWorker).to receive(:perform_async).with("cma-2")
      expect(RepublishWorker).to receive(:perform_async).with("raib-1")
      expect(RepublishWorker).to receive(:perform_async).with("raib-2")

      subject.republish_all
    end
  end

  describe ".republish_document_type" do
    it "enqueues a republish job for all documents of the given type" do
      expect(RepublishWorker).to receive(:perform_async).with("cma-1")
      expect(RepublishWorker).to receive(:perform_async).with("cma-2")
      expect(RepublishWorker).not_to receive(:perform_async).with("raib-1")

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

      expect_any_instance_of(RepublishWorker).to receive(:perform).with("content-id")
      expect_any_instance_of(RepublishWorker).not_to receive(:perform).with("raib-1")

      subject.republish_one("content-id")
    end
  end

  describe ".republish_many" do
    it "enqueues a republish job for the given content ids" do
      expect(RepublishWorker).to receive(:perform_async).with("content-id")
      expect(RepublishWorker).not_to receive(:perform_async).with("raib-1")

      subject.republish_many("content-id")
    end

    it "can run multiple content items from a space separated list" do
      expect(RepublishWorker).to receive(:perform_async).with("content-id-1")
      expect(RepublishWorker).to receive(:perform_async).with("content-id-2")

      subject.republish_many("content-id-1 content-id-2")
    end
  end
end
