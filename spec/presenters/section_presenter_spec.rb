require "spec_helper"

RSpec.describe SectionPresenter do
  let(:manual_content_id) { SecureRandom.uuid }
  let(:manual_base_path) { "/guidance/content-design" }
  let(:content_id) { SecureRandom.uuid }
  let(:test_time) { "2015-12-03 16:59:13 UTC" }
  let(:manual) do
    { content_id: manual_content_id,
     base_path: manual_base_path,
     details: { body: "" } }
  end
  let(:section) {
    Section.new(content_id: content_id,
                    title: "My new section",
                    summary: "Summary of new section",
                    body: "The body of my new section.",
                    manual_content_id: manual_content_id)
  }

  let(:section_presenter) {
    SectionPresenter.new(section)
  }

  before do
    Timecop.freeze(Time.parse(test_time))
    publishing_api_has_item(manual)
    publishing_api_has_links(content_id: section.manual_content_id, body: {})
  end

  after do
    Timecop.return
  end

  describe "#to_json" do
    let(:presented_data) { section_presenter.to_json }

    it "renders the correct data" do
      expect(presented_data[:base_path]).to eq(section.base_path)
      expect(presented_data[:title]).to eq(section.title)
      expect(presented_data[:description]).to eq(section.summary)
      expect(presented_data[:details][:manual][:base_path]).to eq(manual_base_path)
      expect(presented_data[:public_updated_at]).to eq(test_time.to_datetime.rfc3339)
      expect(presented_data[:routes][0][:path]).to eq(section.base_path)
    end
  end
end
