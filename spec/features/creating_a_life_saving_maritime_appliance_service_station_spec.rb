require "spec_helper"

RSpec.feature "Creating a life saving maritime appliance service station", type: :feature do
  let(:life_saving_maritime_appliance_service_station) { FactoryBot.create(:life_saving_maritime_appliance_service_station) }
  let(:content_id) { life_saving_maritime_appliance_service_station["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:marine_equipment_approved_recommendation_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([life_saving_maritime_appliance_service_station], hash_including(document_type: LifeSavingMaritimeApplianceServiceStation.document_type))
    stub_publishing_api_has_item(life_saving_maritime_appliance_service_station)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new recommendation page" do
    visit "/life-saving-maritime-appliance-service-stations"
    click_link "Add another Life Saving Maritime Appliance Service Station"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/life-saving-maritime-appliance-service-stations/new")
  end

  scenario "creating a new life saving maritime appliance service station with no data" do
    visit "/life-saving-maritime-appliance-service-stations/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
  end

  scenario "creating a new life saving maritime appliance service station with valid data" do
    visit "/life-saving-maritime-appliance-service-stations/new"

    fill_in "Title", with: "Example life saving maritime appliance service station"
    fill_in "Summary", with: "This is the summary of an example life saving maritime appliance service station"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example life saving maritime appliance service station" * 2}"
    select "North west England", from: "Regions in the UK"
    select "Marine evacuation system (MES)", from: "Appliance type"
    select "Bombard Liferafts", from: "Appliance manufacturer"

    expect(page).to have_css("div.govspeak-help")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/service-life-saving-maritime-appliances/example-life-saving-maritime-appliance-service-station",
      "title" => "Example life saving maritime appliance service station",
      "description" => "This is the summary of an example life saving maritime appliance service station",
      "document_type" => "life_saving_maritime_appliance_service_station",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example life saving maritime appliance service station\r\n\r\nThis is the long body of an example life saving maritime appliance service station",
          },
        ],
        "metadata" => {
          "life_saving_maritime_appliance_service_station_regions" => %w[north-west-england],
          "life_saving_maritime_appliance_type" => %w[marine-evacuation-system],
          "life_saving_maritime_appliance_manufacturer" => %w[bombard-liferafts],
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/service-life-saving-maritime-appliances/example-life-saving-maritime-appliance-service-station", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[cfc808eb-1c34-49d1-bfbd-e14dcb2c6bbe],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example life saving maritime appliance service station")
    expect(page).to have_content("Bulk published false")
  end

  scenario "creating a life saving maritime appliance service station with invalid data" do
    visit "/life-saving-maritime-appliance-service-stations/new"

    fill_in "Title", with: "Example life saving maritime appliance service station"
    fill_in "Summary", with: "This is the summary of an example life saving maritime appliance service station"
    fill_in "Body", with: "<script>alert('hello')</script>"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Body cannot include invalid Govspeak")
  end
end
