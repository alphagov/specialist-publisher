require "rails_helper"
require "app/presenters/attachment_presenter"

RSpec.describe AttachmentPresenter do
  let(:content_id) { SecureRandom.uuid }
  let(:attachment) do
    Attachment.new(
      url: "path/to/file/in/asset/manger",
      content_type: "application/jpeg",
      title: "test specialist document attachment",
      content_id:,
    )
  end

  let(:attachment_presenter) do
    AttachmentPresenter.new(attachment)
  end

  before do
    Timecop.freeze(Time.zone.parse("2015-12-03 16:59:13 UTC"))
  end

  after do
    Timecop.return
  end

  describe "#to_json" do
    let(:presented_data) { attachment_presenter.to_json }

    it "renders the correct data" do
      expect(presented_data[:url]).to eq("path/to/file/in/asset/manger")
      expect(presented_data[:content_type]).to eq("application/jpeg")
      expect(presented_data[:content_id]).to eq(content_id)
      expect(presented_data[:title]).to eq("test specialist document attachment")
      expect(presented_data[:created_at]).to eq("2015-12-03T16:59:13+00:00")
    end

    it "sets updated_at to the current time" do
      expect(presented_data[:updated_at]).to eq("2015-12-03T16:59:13+00:00")
    end
  end
end
