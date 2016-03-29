require 'rails_helper'

describe ManualLinksPresenter do
  let(:manual) {
    Manual.new({
      body: 'test body content for manual',
      summary: 'test manual summary',
      title: 'test manual title',
      content_id: SecureRandom.uuid,
      organisation_content_ids: organisation_content_id
    })
  }

  let(:content_id) { manual.content_id }
  let(:organisation_content_id) { SecureRandom.uuid }

  let(:manual_links_presenter) { described_class.new(manual) }

  describe "#to_json" do
    let(:presented_data) { manual_links_presenter.to_json }
    it "renders the correct data" do
      expect(presented_data[:content_id]).to eq(content_id)
      expect(presented_data[:links][:organisations]).to eq(manual.organisation_content_ids)
    end
  end
end
