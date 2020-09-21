require "spec_helper"

RSpec.feature "Editing a UK market conformity assessment body", type: :feature do
  let(:body_document) { FactoryBot.create(:uk_market_conformity_assessment_body) }
  let(:content_id) { body_document["content_id"] }
  let(:locale) { body_document["locale"] }
  let(:public_updated_at) { body_document["public_updated_at"] }

  before do
    allow_any_instance_of(DocumentPolicy).to receive(:departmental_editor?).and_return(true)

    log_in_as_editor(:gds_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_item(body_document)
  end

  scenario "with valid data" do
    visit  "/uk-market-conformity-assessment-bodies/#{content_id}:#{locale}/edit"
    expect(page).to have_css("div.govspeak-help")

    title = "Example Company Ltd"
    summary = "This is the summary of a body"

    fill_in "Title", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: "## Header\n\nThis is some text"
    fill_in "Body Number", with: "AB - 1234"
    select "United Kingdom", from: "Registered Office Location"

    click_button "Save as draft"
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Updated Example Company Ltd")
  end
end
