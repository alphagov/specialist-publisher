require "spec_helper"

RSpec.describe ReportDocumentPaginator do
  describe ".each" do
    let(:content_fields) { [:content_id] }

    let(:first_item) { { "content_id" => "a" } }
    let(:second_item) { { "content_id" => "b" } }
    let(:third_item) { { "content_id" => "c" } }

    let(:all_items) { [first_item, second_item, third_item] }

    before do
      publishing_api_has_content(
        all_items,
        document_type: "asylum_support_decision",
        fields: content_fields,
        page: 1,
        per_page: 2,
        order: "-last_edited_at",
        publishing_app: "specialist-publisher",
      )

      publishing_api_has_content(
        all_items,
        document_type: "asylum_support_decision",
        fields: content_fields,
        page: 2,
        per_page: 2,
        order: "-last_edited_at",
        publishing_app: "specialist-publisher",
      )
    end

    let(:subject) { described_class.new(AsylumSupportDecision, content_fields, per_page: 2) }

    it "calls the supplied block with each document hash returned from the publishing api across successive pages" do
      expect { |b| subject.each(&b) }.to yield_successive_args(first_item, second_item, third_item)
    end
  end
end
