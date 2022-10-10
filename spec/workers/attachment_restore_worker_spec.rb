require "rails_helper"

RSpec.describe AttachmentRestoreWorker do
  let(:existing_attachments) do
    [
      {
        "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
        "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
        "content_type" => "application/jpeg",
        "title" => "asylum report image title",
        "created_at" => "2015-12-03T16:59:13+00:00",
        "updated_at" => "2015-12-03T16:59:13+00:00",
      },
      {
        "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
        "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000004/asylum-support-pdf.pdf",
        "content_type" => "application/pdf",
        "title" => "asylum report pdf title",
        "created_at" => "2015-12-03T16:59:13+00:00",
        "updated_at" => "2015-12-03T16:59:13+00:00",
      },
    ]
  end

  let(:content_id) { SecureRandom.uuid }
  let(:locale) { "en" }

  let!(:document) do
    FactoryBot.create(
      :cma_case,
      :published,
      content_id:,
    )
  end

  before do
    document["details"]["attachments"] = existing_attachments
    stub_publishing_api_has_item(document)
  end

  describe "perform" do
    it "calls delete_asset on the asset API for each attachment" do
      expect(Services.asset_api).to receive(:restore_asset).once.ordered
        .with("513a0efbed915d425e000002")
      expect(Services.asset_api).to receive(:restore_asset).once.ordered
        .with("513a0efbed915d425e000004")

      subject.perform(content_id, locale)
    end
  end
end
