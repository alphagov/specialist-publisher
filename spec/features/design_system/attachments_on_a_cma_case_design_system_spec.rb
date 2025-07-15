require "spec_helper"
require "gds_api/test_helpers/support_api"
require "gds_api/test_helpers/publishing_api"
require "gds_api/test_helpers/asset_manager"

RSpec.feature "Attachments on a CMA case", type: :feature do
  include WebMock::API
  include GdsApi::TestHelpers::SupportApi
  include GdsApi::TestHelpers::PublishingApi
  include GdsApi::TestHelpers::AssetManager

  let(:cma_case) do
    FactoryBot.create(:cma_case, :draft, title: "Example CMA Case", details: {
      "attachments" => existing_attachments,
    })
  end
  let(:content_id) { cma_case["content_id"] }
  let(:locale) { cma_case["locale"] }
  let(:asset_manager_response) do
    {
      id: "another_image_id",
      file_url: "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/cma_case_image.jpg",
    }
  end
  let(:existing_attachments) do
    [
      {
        "attachment_type" => "file",
        "id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
        "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
        "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000001/asylum-support-image.jpg",
        "content_type" => "application/jpg",
        "title" => "asylum report image title",
        "created_at" => "2015-12-03T16:59:13+00:00",
        "updated_at" => "2015-12-03T16:59:13+00:00",
      },
      {
        "attachment_type" => "file",
        "id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
        "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
        "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
        "content_type" => "application/pdf",
        "title" => "asylum report pdf title",
        "created_at" => "2015-12-03T16:59:13+00:00",
        "updated_at" => "2015-12-03T16:59:13+00:00",
      },
    ]
  end

  before do
    WebMock.reset!
    log_in_as_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.document_type))
    stub_publishing_api_has_item(cma_case)

    stub_any_support_api_call
  end

  context "no existing attachments" do
    let(:existing_attachments) { [] }

    scenario "don't show attachment links" do
      visit "/cma-cases/#{content_id}:#{locale}"
      click_link "Edit document"

      expect(page).to have_content("Add attachment")
      expect(page).to_not have_content("Edit attachment")
      expect(page).to_not have_content("Delete attachment")
      expect(page).to_not have_content("asylum report")
    end
  end

  scenario "adding an attachment to a CMA case" do
    stub_request = stub_asset_manager_receives_an_asset(filename: "cma_case_image.jp")

    visit "/cma-cases/#{content_id}:#{locale}"
    click_link "Edit document"

    click_link "Add attachment"
    fill_in "Title", with: "New cma case image"
    page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")
    click_button "Save attachment"

    expect(page).to have_content("Editing Example CMA Case")
    expect(page).to have_content("Attached New cma case image")

    assert_requested(stub_request)
  end

  scenario "adding a nil attachment on a CMA case" do
    visit "/cma-cases/#{content_id}:#{locale}"
    click_link "Edit document"

    click_link "Add attachment"
    fill_in "Title", with: "New cma case image"
    click_button "Save attachment"

    expect(page).to have_content("Add attachment")
    expect(page).to_not have_content("Editing CMA Case")
    expect(page).to have_content("Adding an attachment failed. Please make sure you have uploaded an attachment")
  end

  scenario "editing an attachment on a CMA case" do
    stub_request = stub_asset_manager_update_asset("513a0efbed915d425e000001")

    visit "/cma-cases/#{content_id}:#{locale}"
    click_link "Edit document"

    click_link "Edit attachment", match: :first
    fill_in "Title", with: "New cma case image"
    page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")
    click_button "Save attachment"

    expect(page).to have_content("Editing Example CMA Case")
    expect(page).to have_content("Updated New cma case image")

    assert_requested(stub_request)
  end

  scenario "deleting an attachment on a CMA case" do
    stub_request = stub_asset_manager_delete_asset("513a0efbed915d425e000001")

    visit "/cma-cases/#{content_id}:#{locale}"
    click_link "Edit document"

    click_link "Delete attachment", match: :first
    click_button "Delete"

    expect(page).to have_content("Editing Example CMA Case")
    expect(page).to have_content("Attachment successfully removed")

    assert_requested(stub_request)
  end

  context "when the document is in an invalid state" do
    let(:cma_case) do
      FactoryBot.create(:cma_case, :draft, title: "Example CMA Case", details: {
        "body" => "",
        "attachments" => existing_attachments,
      })
    end

    scenario "successfully add and edit attachments on an invalid document" do
      stub_asset_manager_receives_an_asset(filename: "cma_case_image.jp")
      stub_asset_manager_update_asset("513a0efbed915d425e000001")

      visit "/cma-cases/#{content_id}:#{locale}"
      click_link "Edit document"

      click_link "Add attachment"
      fill_in "Title", with: "New cma case image"
      page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")
      click_button "Save attachment"

      expect(page).to have_content("Editing Example CMA Case")
      expect(page).to have_content("Attached New cma case image")
      expect(page.find_field("Body")).to have_content("")

      click_link "Edit attachment", match: :first
      fill_in "Title", with: "New cma case image 2"
      page.attach_file("attachment_file", "spec/support/images/cma_case_image.jpg")
      click_button "Save attachment"

      expect(page).to have_content("Editing Example CMA Case")
      expect(page).to have_content("Updated New cma case image 2")
      expect(page.find_field("Body")).to have_content("")
    end
  end
end
