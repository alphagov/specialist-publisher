require "spec_helper"

RSpec.feature "Unpublishing a UK market conformity assessment body", type: :feature do
  let(:content_id) { item["content_id"] }
  let(:locale) { item["locale"] }

  before do
    log_in_as_editor(:gds_editor)
    stub_publishing_api_has_item(item)
  end

  context "a published document" do
    let(:item) do
      FactoryBot.create(
        :uk_market_conformity_assessment_body,
        title: "Example UKMCAB",
        publication_state: "published",
      )
    end

    scenario "entering a reason for unpublishing in the internal note field" do
      stub_publishing_api_unpublish(content_id, body: { type: "gone", explanation: "foo", locale: locale })
      visit "/uk-market-conformity-assessment-bodies/#{content_id}:#{locale}"

      fill_in "internal_notes", with: "foo"
      click_button "Unpublish document"
      expect(page).to have_content("Unpublished Example UKMCAB")
      expect(page.status_code).to eq(200)
      assert_publishing_api_unpublish(content_id)

      expect(page).to have_content("Internal notes")
      expect(page).to have_content("Foo")
    end
  end
end
