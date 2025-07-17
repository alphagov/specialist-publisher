require "spec_helper"

RSpec.feature "Creating a Trademark Decision", type: :feature do
  let(:trademark_decision) do
    FactoryBot.create(
      :trademark_decision,
      default_metadata: {
        trademark_decision_grounds_section: ["section-3-1-graphical-representation"],
        trademark_decision_grounds_sub_section: ["section-3-1-graphical-representation-is-it-a-sign"],
      },
    )
  end
  let(:content_id) { trademark_decision["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save")["data-disable-with"] }

  before do
    log_in_as_editor(:gds_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([trademark_decision], hash_including(document_type: TrademarkDecision.document_type))
    stub_publishing_api_has_item(trademark_decision)
  end

  scenario "getting to the new document page" do
    visit "/trademark-decisions"
    click_link "Add another Trademark Decision"

    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/trademark-decisions/new")
  end

  scenario "persists nested facets upon validation with errors" do
    visit "/trademark-decisions/new"

    select "Section 3(1) Graphical Representation - Is it a sign?", from: "Grounds Section"
    click_button "Save"

    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Section 3(1) Graphical Representation - Is it a sign?")
  end

  scenario "with valid data" do
    visit "/trademark-decisions/new"

    fill_in "Title", with: "Example document"
    fill_in "Summary", with: "This is the summary of an example"
    fill_in "Body", with: "This is the long body of an example"

    select "Registrar – Inter partes interlocutory hearings", from: "Type of hearing"
    select "1", from: "Class"
    fill_in "trademark_decision[trademark_decision_date(1i)]", with: "2022"
    fill_in "trademark_decision[trademark_decision_date(2i)]", with: "02"
    fill_in "trademark_decision[trademark_decision_date(3i)]", with: "02"
    select "Mr N Abraham", from: "Appointed person/hearing officer"
    select "Section 3(1) Graphical Representation - Is it a sign?", from: "Grounds Section"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")

    click_button "Save"

    expected_sent_payload = {
      "base_path": "/trademark-decisions/example-document",
      "title": "Example document",
      "description": "This is the summary of an example",
      "document_type": "trademark_decision",
      "schema_name": "specialist_document",
      "publishing_app": "specialist-publisher",
      "rendering_app": "frontend",
      "locale": "en",
      "phase": "live",
      "details": {
        "body": [
          {
            "content_type": "text/govspeak",
            "content": "This is the long body of an example",
          },
        ],
        "metadata": {
          "trademark_decision_type_of_hearing": "registrar-inter-partes-interlocutory-hearings",
          "trademark_decision_class": "1",
          "trademark_decision_date": "2022-02-02",
          "trademark_decision_appointed_person_hearing_officer": "mr-n-abraham",
          "trademark_decision_grounds_section": [
            "section-3-1-graphical-representation",
          ],
          "trademark_decision_grounds_sub_section": [
            "section-3-1-graphical-representation-is-it-a-sign",
          ],
        },
        "max_cache_time": 10,
        "temporary_update_type": false,
      },
      "routes": [
        {
          "path": "/trademark-decisions/example-document",
          "type": "exact",
        },
      ],
      "redirects": [],
      "update_type": "major",
      "links": {
        "finder": %w[
          9f8388a8-9559-4a75-96f3-4a0a1027b5e8
        ],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example document")
    expect(page).to have_content("Grounds Section Section 3(1) Graphical Representation")
    expect(page).to have_content("Grounds Sub Section Section 3(1) Graphical Representation - Is it a sign?")
    expect(page).to have_content("Bulk published false")
  end
end
