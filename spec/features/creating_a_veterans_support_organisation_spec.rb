require "spec_helper"

RSpec.feature "Creating a veterans support organisation", type: :feature do
  let(:veterans_support_organisation) { FactoryBot.create(:veterans_support_organisation) }
  let(:content_id) { veterans_support_organisation["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:gds_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([veterans_support_organisation], hash_including(document_type: SpecialistDocument::VeteransSupportOrganisation.document_type))
    stub_publishing_api_has_item(veterans_support_organisation)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new recommendation page" do
    visit "/veterans-support-organisations"
    click_link "Add another Veterans Support Organisation"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/veterans-support-organisations/new")
  end

  scenario "creating a new veteran support organisation with no data" do
    visit "/veterans-support-organisations/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "creating a new veteran support organisation with valid data" do
    visit "/veterans-support-organisations/new"

    fill_in "Title", with: "Example veterans support organisation"
    fill_in "Summary", with: "This is the summary of an example veterans support organisation"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example veterans support organisation" * 2}"
    select "Mental Health", from: "Health and Social Care"
    select "Benefits", from: "Finance"
    select "Care homes", from: "Housing"

    expect(page).to have_css("div.govspeak-help")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/support-for-veterans/example-veterans-support-organisation",
      "title" => "Example veterans support organisation",
      "description" => "This is the summary of an example veterans support organisation",
      "document_type" => "veterans_support_organisation",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example veterans support organisation\r\n\r\nThis is the long body of an example veterans support organisation",
          },
        ],
        "metadata" => {
          "veterans_support_organisation_health_and_social_care" => %w[mental-health],
          "veterans_support_organisation_finance" => %w[benefits],
          "veterans_support_organisation_housing" => %w[care-homes],
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/support-for-veterans/example-veterans-support-organisation", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[0bf7f581-a547-4dd1-aef0-754e0924281d],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example veterans support organisation")
    expect(page).to have_content("Bulk published false")
  end

  scenario "creating a veteran support organisation with invalid data" do
    visit "/veterans-support-organisations/new"

    fill_in "Title", with: "Example veterans support organisation"
    fill_in "Summary", with: "This is the summary of an example veterans support organisation"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
