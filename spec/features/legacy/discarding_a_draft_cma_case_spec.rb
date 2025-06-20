require "spec_helper"

RSpec.feature "Discarding a draft CMA Case", type: :feature do
  let(:content_id) { item["content_id"] }
  let(:locale) { item["locale"] }

  before do
    stub_publishing_api_has_item(item)
    stub_publishing_api_discard_draft(content_id)
    stub_publishing_api_has_content([item], hash_including(document_type: CmaCase.document_type))
  end

  context "a draft document" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        title: "Example CMA Case",
        publication_state: "draft",
      )
    end

    context "as a CMA editor" do
      scenario "clicking the discard button discards the draft" do
        log_in_as_editor(:cma_editor)
        visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")
        expect(page).to have_content("Example CMA Case")
        click_button "Discard draft"
        expect(page.status_code).to eq(200)
        expect(page).to have_content("Discarded draft of Example CMA Case")

        assert_publishing_api_discard_draft(content_id)
        expect(current_path).to eq(documents_path(document_type_slug: "cma-cases"))
      end
    end

    context "as a writer" do
      scenario "no discard draft button is visible" do
        log_in_as_editor(:cma_writer)
        visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")

        expect(page).to have_content("You don't have permission to discard this draft")
        expect(page).to have_no_selector(:button, "Discard draft")
      end
    end
  end

  context "a published document with no draft" do
    let(:item) do
      FactoryBot.create(
        :cma_case,
        title: "Example CMA Case",
        publication_state: "published",
      )
    end

    scenario "where no draft exists" do
      log_in_as_editor(:cma_editor)
      visit document_path(content_id_and_locale: "#{content_id}:#{locale}", document_type_slug: "cma-cases")

      expect(page).to have_content("There is no draft to discard")
      expect(page).to have_no_selector(:button, "Discard draft")
    end
  end
end
