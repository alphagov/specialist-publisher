require "spec_helper"

RSpec.feature "Creating a marine equipment approved recommendation", type: :feature do
  let(:marine_equipment_approved_recommendation) { FactoryBot.create(:marine_equipment_approved_recommendation) }
  let(:content_id) { marine_equipment_approved_recommendation["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:marine_equipment_approved_recommendation_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([marine_equipment_approved_recommendation], hash_including(document_type: SpecialistDocument::MarineEquipmentApprovedRecommendation.document_type))
    stub_publishing_api_has_item(marine_equipment_approved_recommendation)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new recommendation page" do
    visit "/marine-equipment-approved-recommendations"
    click_link "Add another Marine Equipment Approved Recommendation"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/marine-equipment-approved-recommendations/new")
  end

  scenario "creating a new marine equipment approved recommendation with no data" do
    visit "/marine-equipment-approved-recommendations/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "creating a new marine equipment approved recommendation with valid data" do
    visit "/marine-equipment-approved-recommendations/new"

    fill_in "Title", with: "Example marine equipment approved recommendation"
    fill_in "Summary", with: "This is the summary of an example marine equipment approved recommendation"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example marine equipment approved recommendation" * 2}"
    fill_in "Year adopted", with: "2021"
    fill_in "Reference number", with: "ABC123"
    fill_in "Keyword", with: "keyword"
    select "Marine pollution prevention", from: "Category"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/marine-equipment-approved-recommendations/example-marine-equipment-approved-recommendation",
      "title" => "Example marine equipment approved recommendation",
      "description" => "This is the summary of an example marine equipment approved recommendation",
      "document_type" => "marine_equipment_approved_recommendation",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example marine equipment approved recommendation\r\n\r\nThis is the long body of an example marine equipment approved recommendation",
          },
        ],
        "metadata" => {
          "category" => %w[marine-pollution-prevention],
          "year_adopted" => "2021",
          "reference_number" => "ABC123",
          "keyword" => "keyword",
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/marine-equipment-approved-recommendations/example-marine-equipment-approved-recommendation", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[49f47764-2b1b-4b0d-9164-4aa6b42a8b63],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example marine equipment approved recommendation")
    expect(page).to have_content("Bulk published false")
  end

  scenario "creating a marine equipment approved recommendation with an invalid data" do
    visit "/marine-equipment-approved-recommendations/new"

    fill_in "Title", with: "Example marine equipment approved recommendation"
    fill_in "Summary", with: "This is the summary of an example marine equipment approved recommendation"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example marine equipment approved recommendation" * 2}"
    fill_in "Year adopted", with: "abc123"
    fill_in "Reference number", with: "ABC123"
    fill_in "Keyword", with: "keyword"
    select "Marine pollution prevention", from: "Category"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Year adopted is invalid")
  end

  scenario "creating a marine equipment approved recommendation with invalid data" do
    visit "/marine-equipment-approved-recommendations/new"

    fill_in "Title", with: "Example marine equipment approved recommendation"
    fill_in "Summary", with: "This is the summary of an example marine equipment approved recommendation"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
