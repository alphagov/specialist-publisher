require "spec_helper"

RSpec.feature "Creating an sfo Case", type: :feature do
  let(:sfo_case) { FactoryBot.create(:sfo_case) }
  let(:content_id) { sfo_case["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:sfo_case_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([sfo_case], hash_including(document_type: SfoCase.document_type))
    stub_publishing_api_has_item(sfo_case)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new document page" do
    visit "/sfo-cases"
    click_link "Add another SFO Case"

    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/sfo-cases/new")
  end

  scenario "with valid data" do
    visit "/sfo-cases/new"

    fill_in "Title", with: "Example sfo Case"
    fill_in "Summary", with: "This is the summary of an example sfo case"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example life saving maritime appliance service station" * 2}"
    select "Closed", from: "Case state"
    fill_in "Date announced", with: "2023-01-01"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/sfo-cases/example-sfo-case",
      "title" => "Example sfo Case",
      "description" => "This is the summary of an example sfo case",
      "document_type" => "sfo_case",
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
              "content" => "## Header\r\n\r\nThis is the long body of an example life saving maritime appliance service station\r\n\r\nThis is the long body of an example life saving maritime appliance service station",
            },
          ],
        "metadata" => {
          "sfo_case_state" => "closed",
          "sfo_case_date_announced" => "2023-01-01",
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [
        {
          "path" => "/sfo-cases/example-sfo-case",
          "type" => "exact",
        },
      ],
      "redirects" => [],
      "update_type" => "major",
      "links" =>
        {
          "finder" => %w[b8b8fb77-c5e9-41d6-b133-44ecd1958e28],
        },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example sfo Case")
    expect(page).to have_content("Bulk published false")
  end

  scenario "with no data" do
    visit "/sfo-cases/new"

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
    visit "/sfo-cases/new"

    fill_in "Title", with: "Example sfo Case"
    fill_in "Summary", with: "This is the summary of an example sfo case"
    fill_in "Body", with: "<script>alert('hello')</script>"
    fill_in "Date announced", with: "invalid_date"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_css(".elements-error-summary")
    expect(page).to have_css(".elements-error-message")

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
    expect(page).to have_content("Sfo case date announced is not a valid date")
  end
end
