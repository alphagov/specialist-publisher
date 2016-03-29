require 'rails_helper'

describe ManualPresenter do
  let(:manual) {
    Manual.new({
      body: 'test body content for manual',
      summary: 'test manual summary',
      title: 'test manual title',
      content_id: SecureRandom.uuid
    })
  }

  let(:content_id) { manual.content_id }
  let(:manual_presenter) { ManualPresenter.new(manual) }

  before do
    Timecop.freeze(Time.parse("2015-12-03 16:59:13 UTC"))
  end

  after do
    Timecop.return
  end

  describe "#to_json" do
    let(:presented_data) { manual_presenter.to_json }
    it "renders the correct data" do
      expect(presented_data[:base_path]).to eq("/guidance/test-manual-title")
      expect(presented_data[:details][:body]).to eq('test body content for manual')
      expect(presented_data[:content_id]).to eq(content_id)
      expect(presented_data[:title]).to eq('test manual title')
      expect(presented_data[:public_updated_at]).to eq("2015-12-03T16:59:13+00:00")
      expect(presented_data[:description]).to eq('test manual summary')
    end

  end
end

