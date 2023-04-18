require "spec_helper"

RSpec.feature "Creating an animal disease case", type: :feature do
  let(:animal_disease_case) { FactoryBot.create(:animal_disease_case) }
  let(:content_id) { animal_disease_case["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:animal_disease_case_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([animal_disease_case], hash_including(document_type: AnimalDiseaseCase.document_type))
    stub_publishing_api_has_item(animal_disease_case)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new case page" do
    #  ? should this be animal disease cases england?
    visit "/animal-disease-cases"
    click_link "Add another animal disease case"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/animal-disease-cases/new")
  end

  scenario "creating a new animal disease case with no data" do
    visit "/animal-disease-cases/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Please fix the following errors")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).to have_content("Disease type can't be blank")
    expect(page).to have_content("Zone restriction can't be blank")
    expect(page).to have_content("Opened date can't be blank")
  end

  scenario "creating a new animal disease case with valid data" do
    visit "/animal-disease-cases/new"

    fill_in "Title", with: "Example animal disease case"
    fill_in "Summary", with: "This is the summary of an example animal disease case"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example animal disease case" * 2}"
    fill_in "[animal_disease_case]disease_case_opened_date(1i)", with: "2022"
    fill_in "[animal_disease_case]disease_case_opened_date(2i)", with: "09"
    fill_in "[animal_disease_case]disease_case_opened_date(3i)", with: "09"
    fill_in "[animal_disease_case]disease_case_closed_date(1i)", with: "2022"
    fill_in "[animal_disease_case]disease_case_closed_date(2i)", with: "10"
    fill_in "[animal_disease_case]disease_case_closed_date(3i)", with: "09"
    select "Bird flu (avian influenza)", from: "Disease type"
    select "In force", from: "Disease control zone restriction"
    select "Protection zone", from: "Zone type"
    select "H5Nx", from: "Virus strain"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/animal-disease-cases-england/example-animal-disease-case",
      "title" => "Example animal disease case",
      "description" => "This is the summary of an example animal disease case",
      "document_type" => "animal_disease_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example animal disease case\r\n\r\nThis is the long body of an example animal disease case",
          },
        ],
        "metadata" => {
          "disease_type" => %w[bird-flu],
          "zone_restriction" => "in-force",
          "zone_type" => %w[protection],
          "virus_strain" => "h5nx",
          "disease_case_opened_date" => "2022-09-09",
          "disease_case_closed_date" => "2022-10-09",
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/animal-disease-cases-england/example-animal-disease-case", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[48ef3920-b877-47af-8356-44f345c22a47],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example animal disease case")
    expect(page).to have_content("Bulk published false")
  end

  scenario "creating an animal disease case with an invalid dates" do
    visit "/animal-disease-cases/new"

    fill_in "Title", with: "Example animal disease case"
    fill_in "Summary", with: "This is the summary of an example animal disease case"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example animal disease case" * 2}"
    fill_in "[animal_disease_case]disease_case_opened_date(1i)", with: "2021"
    fill_in "[animal_disease_case]disease_case_opened_date(2i)", with: "02"
    fill_in "[animal_disease_case]disease_case_opened_date(3i)", with: "31"
    fill_in "[animal_disease_case]disease_case_closed_date(1i)", with: "2020"
    fill_in "[animal_disease_case]disease_case_closed_date(2i)", with: "02"
    fill_in "[animal_disease_case]disease_case_closed_date(3i)", with: "20"
    select "Bird flu (avian influenza)", from: "Disease type"
    select "In force", from: "Disease control zone restriction"
    select "Protection zone", from: "Zone type"
    select "H5Nx", from: "Virus strain"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Please fix the following errors")
    expect(page).to have_content("Opened date is not a valid date")
    expect(page).to have_content("Opened date must be before closed date")
  end

  scenario "creating an animal disease case with invalid data" do
    visit "/animal-disease-cases/new"

    fill_in "Title", with: "Example animal disease case"
    fill_in "Summary", with: "This is the summary of an example animal disease case"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("Please fix the following errors")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
