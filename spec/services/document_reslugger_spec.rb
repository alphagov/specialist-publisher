require "rails_helper"

RSpec.describe DocumentReslugger do
  subject(:reslugger) { described_class.new(document_type, finder_base_path) }

  let(:document_type) { "veterans_support_organisation" }
  let(:finder_base_path) { "/veteran-support-organisations" }
  let(:old_base_path) { "/support-for-veterans" }
  let(:klass) { class_double(Document, document_type:) }

  before do
    allow(Rails.application).to receive(:eager_load!)
    allow(Document).to receive(:subclasses).and_return([klass])
    allow(klass).to receive(:find_each)
  end

  def stub_document(base_path:, publication_state:, content_id: "content-id")
    instance_double(
      Document,
      content_id:,
      locale: "en",
      base_path:,
      publication_state:,
      published?: publication_state == "published",
      draft?: publication_state == "draft",
      :base_path= => nil,
      :update_type= => nil,
      save: true,
      publish: true,
    )
  end

  describe "#reslug_all" do
    it "raises for an unknown document type" do
      expect { described_class.new("not_a_real_type", finder_base_path).reslug_all }
        .to raise_error(ArgumentError, /not_a_real_type/)
    end

    it "reslugs and publishes a published document" do
      document = stub_document(base_path: "#{old_base_path}/foo", publication_state: "published")
      allow(klass).to receive(:find_each).and_yield(document)

      report = reslugger.reslug_all

      expect(document).to have_received(:base_path=).with("#{finder_base_path}/foo")
      expect(document).to have_received(:update_type=).with("minor")
      expect(document).to have_received(:save)
      expect(document).to have_received(:publish)
      expect(report.published).to eq(["#{finder_base_path}/foo"])
    end

    it "reslugs but keeps a draft document in draft" do
      document = stub_document(base_path: "#{old_base_path}/bar", publication_state: "draft")
      allow(klass).to receive(:find_each).and_yield(document)

      report = reslugger.reslug_all

      expect(document).to have_received(:base_path=).with("#{finder_base_path}/bar")
      expect(document).to have_received(:save)
      expect(document).not_to have_received(:publish)
      expect(report.drafted).to eq(["#{finder_base_path}/bar"])
    end

    it "skips an unpublished document" do
      document = stub_document(base_path: "#{old_base_path}/baz", publication_state: "unpublished")
      allow(klass).to receive(:find_each).and_yield(document)

      report = reslugger.reslug_all

      expect(document).not_to have_received(:save)
      expect(document).not_to have_received(:publish)
      expect(report.skipped).to eq(["#{old_base_path}/baz (unpublished)"])
    end

    it "skips a document already at the finder base_path" do
      document = stub_document(base_path: "#{finder_base_path}/thing", publication_state: "published")
      allow(klass).to receive(:find_each).and_yield(document)

      report = reslugger.reslug_all

      expect(document).not_to have_received(:save)
      expect(report.skipped).to eq(["#{finder_base_path}/thing (published)"])
    end

    it "records a failure and continues with the next document" do
      failing = stub_document(content_id: "doc-5", base_path: "#{old_base_path}/fail", publication_state: "published")
      allow(failing).to receive(:save).and_return(false)
      allow(failing).to receive(:errors).and_return(
        instance_double(ActiveModel::Errors, full_messages: ["conflicts with content_id"]),
      )
      ok = stub_document(base_path: "#{old_base_path}/ok", publication_state: "published")
      allow(klass).to receive(:find_each).and_yield(failing).and_yield(ok)

      report = reslugger.reslug_all

      expect(ok).to have_received(:publish)
      expect(report.published).to eq(["#{finder_base_path}/ok"])
      expect(report.failed).to eq(["doc-5 (en) - conflicts with content_id"])
    end

    it "records a failure and continues when a document raises unexpectedly" do
      document = instance_double(Document, content_id: "doc-7", locale: "en")
      allow(document).to receive(:base_path).and_raise(StandardError, "boom")
      allow(klass).to receive(:find_each).and_yield(document)

      report = reslugger.reslug_all

      expect(report.failed).to eq(["doc-7 (en) - boom"])
    end

    it "returns a report of the results" do
      expect(reslugger.reslug_all).to be_a(DocumentReslugger::Report)
    end
  end

  describe DocumentReslugger::Report do
    it "formats each category with its count and paths" do
      report = described_class.new(["/a", "/b"], ["/c"], [], ["doc-1 (en) - boom"])

      expect(report.to_s).to eq(<<~REPORT.chomp)
        Published 2:
        /a
        /b
        Drafted 1:
        /c
        Skipped 0:
        Failed 1:
        doc-1 (en) - boom
      REPORT
    end
  end
end
