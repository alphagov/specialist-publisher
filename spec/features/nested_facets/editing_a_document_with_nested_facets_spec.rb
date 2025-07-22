require "spec_helper"

RSpec.feature "Editing a document with nested facets (Trademark Decision)", type: :feature do
  let(:trademark_decision) { FactoryBot.create(:trademark_decision, title: "Example document", state_history: { "1" => "draft" }) }
  let(:content_id) { trademark_decision["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save")["data-disable-with"] }
  let(:content_id) { trademark_decision["content_id"] }
  let(:locale) { trademark_decision["locale"] }

  before do
    log_in_as_editor(:gds_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_content([trademark_decision], hash_including(document_type: TrademarkDecision.document_type))
    stub_publishing_api_has_item(trademark_decision)
  end

  scenario "renders and persists nested facets" do
    trademark_decision["trademark_decision_sub_section"] = "section-3-1-graphical-representation-is-it-graphically-represented"

    visit "/trademark-decisions/#{content_id}:#{locale}"
    click_link "Edit document"

    expect(page).to have_content("Section 3(1) Graphical Representation - Is it graphically represented?")

    fill_in "Title", with: ""
    click_button "Save"

    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Section 3(1) Graphical Representation - Is it graphically represented?")
  end

  scenario "update draft" do
    updated_trademark_decision = {
      "base_path": "/trademark-decisions/example-document",
      "title": "Example document",
      "description": "This is the summary of example document",
      "document_type": "trademark_decision",
      "schema_name": "specialist_document",
      "publishing_app": "specialist-publisher",
      "rendering_app": "frontend",
      "locale": "en",
      "phase": "live",
      "details": {
        "body": [{ "content_type": "text/govspeak", "content": "default text" }],
        "metadata": {
          "trademark_decision_class": "5",
          "trademark_decision_date": "2015-11-16",
          "trademark_decision_appointed_person_hearing_officer": "mr-n-abraham",
          "trademark_decision_grounds_section": ["section-3-1-graphical-representation", "section-3-3-immoral-and-deceptive-marks"],
          "trademark_decision_grounds_sub_section": ["section-3-1-graphical-representation-is-it-a-sign", "section-3-3-immoral-and-deceptive-marks-contrary-to-public-policy-accepted-principles-of-morality"],
        },
        "max_cache_time": 10,
        "temporary_update_type": false,
      },
      "routes": [{ "path": "/trademark-decisions/example-document", "type": "exact" }],
      "redirects": [],
      "update_type": "major",
      "links": { "finder": %w[9f8388a8-9559-4a75-96f3-4a0a1027b5e8] },
    }

    visit "/trademark-decisions/#{content_id}:#{locale}"
    click_link "Edit document"

    select "5", from: "Class"
    select "Section 3(1) Graphical Representation - Is it a sign?", from: "trademark_decision[trademark_decision_grounds_section][]"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("Add attachments")

    click_button "Save"

    assert_publishing_api_put_content(content_id, updated_trademark_decision)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Example document")
  end
end
