require 'spec_helper'

RSpec.feature "Editing a draft CMA case", type: :feature do
  let(:file_name) { "cma_case_image.jpg" }
  let(:asset_url) { "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/#{file_name}" }
  let(:asset_manager_response) {
    {
      id: 'http://asset-manager.dev.gov.uk/assets/another_image_id',
      file_url: asset_url
    }
  }

  let(:cma_case) {
    Payloads.cma_case_content_item("details" => {
      "attachments" => [
        {
          "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image.jpg",
          "content_type" => "application/jpeg",
          "title" => "asylum report image title",
          "created_at" => "2015-12-03T16:59:13+00:00",
          "updated_at" => "2015-12-03T16:59:13+00:00"
        },
        {
          "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
          "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-pdf.pdf",
          "content_type" => "application/pdf",
          "title" => "asylum report pdf title",
          "created_at" => "2015-12-03T16:59:13+00:00",
          "updated_at" => "2015-12-03T16:59:13+00:00"
        }
      ]
    },
    "publication_state" => "draft")
  }
  let(:content_id) { cma_case['content_id'] }
  let(:fields) { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }
  let(:page_number) { 1 }
  let(:per_page) { 50 }
  before do
    log_in_as_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    publishing_api_has_content([cma_case], hash_including(document_type: CmaCase.publishing_api_document_type))

    publishing_api_has_item(cma_case)


    @changed_json = cma_case.merge(
      "title" => "Changed title",
      "description" => "Changed summary",
      "public_updated_at" => "2015-12-03T16:59:13+00:00",
    )

    @changed_json["details"].merge!(
      "change_history" => [
        {
          "public_timestamp" => "2015-12-03T16:59:13+00:00",
          "note" => "First published.",
        }
      ]
    )

    @changed_json.delete("publication_state")
    Timecop.freeze(Time.parse("2015-12-03T16:59:13+00:00"))

    stub_request(:post, "#{Plek.find('asset-manager')}/assets")
      .with(body: %r{.*})
      .to_return(body: JSON.dump(asset_manager_response), status: 201)
  end

  after do
    Timecop.return
  end

  scenario "with some changed attributes" do
    visit "/cma-cases/#{content_id}"

    click_link "Edit document"

    fill_in "Title", with: "Changed title"
    fill_in "Summary", with: "Changed summary"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 10)
    fill_in "Opened date", with: "2014-01-01"
    select "Energy", from: "Market sector"

    expect(page).to have_css('div.govspeak-help')
    expect(page).to have_content('Add attachment')

    click_button "Save as draft"

    assert_publishing_api_put_content(content_id, request_json_includes(@changed_json))
    expect(@changed_json["content_id"]).to eq(content_id)
    expect(@changed_json["public_updated_at"]).to eq("2015-12-03T16:59:13+00:00")

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Changed title")
  end

  scenario "with some invalid changed attributes" do
    visit "/cma-cases/#{content_id}"

    click_link "Edit document"

    fill_in "Title", with: "Changed title"
    fill_in "Summary", with: "Changed summary"
    fill_in "Body", with: "<script>alert('hello')</script>"
    fill_in "Opened date", with: "Not a date"
    select "Energy", from: "Market sector"

    click_button "Save as draft"

    expect(@changed_json["content_id"]).to eq(content_id)
    expect(page).to have_content("Opened date should be formatted YYYY-MM-DD")
    expect(page).to have_content("Body cannot include invalid Govspeak")

    expect(page.status_code).to eq(422)
  end

  scenario "adding an attachment" do
    visit "/cma-cases/#{content_id}"

    click_link "Edit document"

    click_link "Add attachment"
    expect(page.status_code).to eq(200)

    fill_in "Title", with: "New cma case image"
    page.attach_file('attachment_file', "spec/support/images/cma_case_image.jpg")

    click_button "Save attachment"
    expect(page.status_code).to eq(200)

    expect(page).to have_content("Editing Example CMA Case")
  end

  scenario "editing an attachment" do
    visit "/cma-cases/#{content_id}"

    click_link "Edit document"

    find('.attachments').first(:link, "edit").click

    expect(page.status_code).to eq(200)

    fill_in "Title", with: "Updated cma case image"
    page.attach_file('attachment_file', "spec/support/images/updated_cma_case_image.jpg")

    click_button("Save attachment")

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Editing Example CMA Case")
  end
end
