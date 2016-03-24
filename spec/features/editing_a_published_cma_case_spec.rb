require 'spec_helper'

RSpec.feature "Editing a published CMA case", type: :feature do
  def published_cma_case_content_item
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of a published example CMA case",
      "document_type" => "cma_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-23T14:07:47+00:00",
      "publication_state" => "live",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
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
        ],
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "document_type" => "cma_case",
        },
        "change_history" => [
          {
            "public_timestamp" => "2015-11-23T14:07:47+00:00",
            "note" => "First published."
          }
        ]
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end

  def redrafted_cma_case_content_item
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of a redrafted example CMA case",
      "format" => "cma_case",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-23T14:07:47.240Z",
      "details" => {
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
        "metadata" => {
          "opened_date" => "2014-01-01",
          "closed_date" => "",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "outcome_type" => "",
          "document_type" => "cma_case",
        }
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }
  end


  def cma_case_content_item_links
    {
      "content_id" => "4a656f42-35ad-4034-8c7a-08870db7fffe",
      "links" => {
        "organisations" => ["957eb4ec-089b-4f71-ba2a-dc69ac8919ea"]
      }
    }
  end

  let(:fields) { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }

  let(:file_name) { "cma_case_image.jpg" }
  let(:asset_url) { "http://assets-origin.dev.gov.uk/media/56c45553759b740609000000/#{file_name}" }
  let(:asset_manager_response) {
    {
      id: 'http://asset-manager.dev.gov.uk/assets/another_image_id',
      file_url: asset_url
    }
  }

  before do
    log_in_as_editor(:cma_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    publishing_api_has_fields_for_document(CmaCase.publishing_api_document_type, [published_cma_case_content_item], fields)

    publishing_api_has_item(published_cma_case_content_item)

    request = stub_request(:post, "#{Plek.find('asset-manager')}/assets").
      with(body: %r{.*}).
      to_return(body: JSON.dump(asset_manager_response), status: 201)

    Timecop.freeze(Time.parse("2015-12-03 16:59:13 UTC"))
  end

  after do
    Timecop.return
  end

  scenario "with a minor update" do
    changed_json = published_cma_case_content_item.merge("title" => "Minor update title",
      "description" => "Minor update summary",
      "update_type" => "minor",)

    changed_json.delete("publication_state")

    visit "/cma-cases/4a656f42-35ad-4034-8c7a-08870db7fffe"

    click_link "Edit document"

    fill_in "Title", with: "Minor update title"
    fill_in "Summary", with: "Minor update summary"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 10)
    fill_in "Opened date", with: "2014-01-01"

    choose("cma_case_update_type_minor")

    expect(page).to have_css('div.govspeak-help')
    expect(page).to have_content('Add attachment')

    click_button "Save as draft"

    assert_publishing_api_put_content("4a656f42-35ad-4034-8c7a-08870db7fffe", request_json_includes(changed_json))
    expect(changed_json["content_id"]).to eq("4a656f42-35ad-4034-8c7a-08870db7fffe")
    expect(changed_json["public_updated_at"]).to eq("2015-11-23T14:07:47+00:00")

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Minor update title")
  end

  scenario "with a major update" do
    changed_json = published_cma_case_content_item.merge("title" => "Major update title",
      "description" => "Major update summary",
      "public_updated_at" => "2015-12-03T16:59:13+00:00",
      "update_type" => "major",)

    changed_json["details"]["change_history"] << { "public_timestamp" => "2015-12-03T16:59:13+00:00", "note" => "This is a change note." }

    changed_json.delete("publication_state")

    visit "/cma-cases/4a656f42-35ad-4034-8c7a-08870db7fffe"

    click_link "Edit document"

    fill_in "Title", with: "Major update title"
    fill_in "Summary", with: "Major update summary"
    fill_in "Body", with: "## Header" + ("\n\nThis is the long body of an example CMA case" * 10)
    fill_in "Opened date", with: "2014-01-01"

    choose("cma_case_update_type_major")

    fill_in "Change note", with: "This is a change note."

    expect(page).to have_css('div.govspeak-help')
    expect(page).to have_content('Add attachment')

    click_button "Save as draft"

    assert_publishing_api_put_content("4a656f42-35ad-4034-8c7a-08870db7fffe", request_json_includes(changed_json))
    expect(changed_json["content_id"]).to eq("4a656f42-35ad-4034-8c7a-08870db7fffe")
    expect(changed_json["public_updated_at"]).to eq("2015-12-03T16:59:13+00:00")

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Major update title")
  end

  scenario "adding an attachment" do
    visit "/cma-cases/4a656f42-35ad-4034-8c7a-08870db7fffe"

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
    visit "/cma-cases/4a656f42-35ad-4034-8c7a-08870db7fffe"

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
