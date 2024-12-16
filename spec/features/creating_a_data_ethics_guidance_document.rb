require "spec_helper"

RSpec.feature "Creating a Data Ethics Guidance", type: :feature do
  let(:guidance) { FactoryBot.create(:data_ethics_guidance_document) }
  let(:content_id) { guidance["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:gds_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([guidance], hash_including(document_type: DataEthicsGuidanceDocument.document_type))
    stub_publishing_api_has_item(guidance)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new document page" do
    visit "/data-ethics-guidance-documents"
    click_link "Add another Data ethics guidance document"

    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/data-ethics-guidance-documents/new")
  end

  scenario "with valid data" do
    visit "/data-ethics-guidance-documents/new"

    fill_in "Title", with: "Example Guidance Document"
    fill_in "Summary", with: "This is the summary of an example ethics guidance document"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example document" * 2}"
    select "Across Lifecycle", from: "Project phase"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/data-ethics-guidance-hub/example-guidance-document",
      "title" => "Example Guidance Document",
      "description" => "This is the summary of an example ethics guidance document",
      "document_type" => "data_ethics_guidance_document",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase": "live",
      "details" => {
        "body" =>
          [
            {
              "content_type" => "text/govspeak",
              "content" => "## Header\r\n\r\nThis is the long body of an example document\r\n\r\nThis is the long body of an example document",
            },
          ],
        "metadata" => {
          "data_ethics_guidance_document_project_phase" => %w[across-lifecycle],
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [
        {
          "path" => "/data-ethics-guidance-hub/example-guidance-document",
          "type" => "exact",
        },
      ],
      "redirects" => [],
      "update_type" => "major",
      "links" =>
        {
          "finder" => %w[2437862c-56d6-49f9-a5a5-f2a9460cc3ee],
        },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example Guidance Document")
    expect(page).to have_content("Bulk published false")
  end

  scenario "with no data" do
    visit "/data-ethics-guidance-documents/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".form-group.elements-error")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "with invalid data" do
    visit "/data-ethics-guidance-documents/new"

    fill_in "Title", with: "Example Ethics Guidance Document"
    fill_in "Summary", with: "This is the summary of an example Ethics Guidance Document"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
