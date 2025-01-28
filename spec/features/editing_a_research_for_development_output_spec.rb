require "spec_helper"

RSpec.feature "Editing a Research for Development Output", type: :feature do
  let(:research_output)   { FactoryBot.create(:research_for_development_output) }
  let(:content_id)        { research_output["content_id"] }
  let(:locale)            { research_output["locale"] }
  let(:public_updated_at) { research_output["public_updated_at"] }

  before do
    allow_any_instance_of(DocumentPolicy).to receive(:departmental_editor?).and_return(true)

    log_in_as_editor(:research_for_development_output_editor)

    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links

    stub_publishing_api_has_item(research_output)
  end

  scenario "with valid data" do
    visit  "/research-for-development-outputs/#{content_id}:#{locale}/edit"
    expect(page).to have_css("div.govspeak-help")

    title = "Example Research For Development output"
    summary = "This is the summary of an example research fro development output"

    fill_in "Title", with: title
    fill_in "Summary", with: summary
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example research for development output" * 10}"
    fill_in "research_for_development_output[first_published_at(1i)]", with: "2013"
    fill_in "research_for_development_output[first_published_at(2i)]", with: "01"
    fill_in "research_for_development_output[first_published_at(3i)]", with: "01"
    select "United Kingdom", from: "Countries"
    select "Book Chapter", from: "Document type"

    click_button "Save as draft"
    assert_publishing_api_put_content(content_id)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Example Research For Development output")
  end
end
