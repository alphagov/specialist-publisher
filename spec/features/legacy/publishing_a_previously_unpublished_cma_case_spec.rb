require "spec_helper"

RSpec.feature "Publishing a previously unpublished CMA Case", type: :feature do
  let(:content_id) { item["content_id"] }

  let(:existing_attachments) { [] }

  let(:item) do
    FactoryBot.create(
      :cma_case,
      :unpublished,
      title: "Example CMA Case",
      publication_state: "draft",
      state_history: { "1" => "unpublished", "2" => "draft" },
      details: { attachments: existing_attachments },
    )
  end

  before(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, false)
  end

  after(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, true)
  end

  before do
    log_in_as_editor(:cma_editor)

    stub_publishing_api_has_content([item], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(item)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_publishing_api_publish(content_id, {})
    stub_email_alert_api_accepts_content_change

    visit "/cma-cases/#{content_id}"
  end

  context "a new draft of a previously unpublished document with attachments" do
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

    describe "#publish" do
      it "restores the assets via the asset api" do
        expect(Services.asset_api).to receive(:restore_asset).once.ordered
          .with("513a0efbed915d425e000002")
        expect(Services.asset_api).to receive(:restore_asset).once.ordered
          .with("513a0efbed915d425e000004")

        Sidekiq::Testing.inline! { click_on "Publish" }
      end
    end
  end

  context "a new draft of a previously unpublished document without attachments" do
    describe "#publish" do
      it "doesn't call the asset api" do
        expect(Services.asset_api).not_to receive(:restore_asset)

        Sidekiq::Testing.inline! { click_on "Publish" }
      end
    end
  end
end
