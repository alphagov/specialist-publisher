require "spec_helper"
require "gds_api/test_helpers/asset_manager"

RSpec.feature "Temporary update types, relating to attachments", type: :feature do
  include GdsApi::TestHelpers::AssetManager

  let(:payload) { FactoryBot.create(:cma_case, :published) }
  let(:content_id) { payload.fetch("content_id") }
  let(:locale) { payload.fetch("locale") }

  before do
    stub_asset_manager_receives_an_asset("http://example.com/attachment.jpg")

    stub_any_publishing_api_call
    stub_publishing_api_has_item(payload)

    log_in_as_editor(:cma_editor)
  end

  before(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, false)
  end

  after(:each) do
    @test_strategy ||= Flipflop::FeatureSet.current.test!
    @test_strategy.switch!(:show_design_system, true)
  end

  def add_attachment_to_document
    visit "/cma-cases/#{content_id}:#{locale}/attachments/new"

    fill_in "Title", with: "My attachment"
    page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")

    click_button "Save attachment"
    expect(page.status_code).to eq(200)
  end

  context "when the update_type was not set by a user" do
    let(:payload) { FactoryBot.create(:cma_case, :published) }

    scenario "setting temporary_update_type to true and using a minor update_type" do
      add_attachment_to_document

      assert_publishing_api_put_content(
        content_id,
        lambda { |request|
          data = JSON.parse(request.body)

          expect(data.fetch("update_type")).to eq("minor")
          expect(data.fetch("details").fetch("temporary_update_type")).to eq(true)
        },
      )
    end
  end

  context "when the update_type was set by a user" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        :redrafted,
        update_type: "major",
        change_note: "srtj",
        state_history: { "3" => "draft", "2" => "unpublished", "1" => "superseded" },
      )
    end

    scenario "setting temporary_update_type to false and using the existing update_type" do
      add_attachment_to_document

      assert_publishing_api_put_content(
        content_id,
        lambda { |request|
          data = JSON.parse(request.body)

          expect(data.fetch("update_type")).to eq("major")
          expect(data.fetch("details").fetch("temporary_update_type")).to eq(false)
        },
      )
    end
  end

  context "when temporary_update_type was previously set" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        :redrafted,
        update_type: "minor",
        details: {
          temporary_update_type: true,
        },
      )
    end

    scenario "preserving the temporary_update_type" do
      add_attachment_to_document

      assert_publishing_api_put_content(
        content_id,
        lambda { |request|
          data = JSON.parse(request.body)

          expect(data.fetch("update_type")).to eq("minor")
          expect(data.fetch("details").fetch("temporary_update_type")).to eq(true)
        },
      )
    end

    scenario "giving the user a choice of update_type when editing the document" do
      visit "/cma-cases/#{content_id}:#{locale}/edit"
      expect(page.status_code).to eq(200)

      radio_minor = find_field("cma_case_update_type_minor")
      radio_major = find_field("cma_case_update_type_major")

      expect(radio_minor).not_to be_checked
      expect(radio_major).not_to be_checked
    end
  end

  context "when the document is a draft" do
    let(:payload) do
      FactoryBot.create(
        :cma_case,
        publication_state: "draft",
      )
    end

    scenario "reverting to the default behaviour for saving a draft" do
      add_attachment_to_document

      assert_publishing_api_put_content(
        content_id,
        lambda { |request|
          data = JSON.parse(request.body)

          expect(data.fetch("update_type")).to eq("major")
          expect(data.fetch("details").fetch("temporary_update_type")).to eq(false)
        },
      )
    end
  end
end
