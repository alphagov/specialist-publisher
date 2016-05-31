require 'spec_helper'

RSpec.feature "Viewing a specific case", type: :feature do
  let(:cma_cases) { [] }
  before do
    log_in_as_editor(:cma_editor)

    publishing_api_has_content(cma_cases, hash_including(document_type: CmaCase.document_type))
    cma_cases.each do |cma_case|
      publishing_api_has_item(cma_case)
    end
  end

  context "from the index" do
    let(:cma_cases) {
      [
        FactoryGirl.create(:cma_case,
          title: "Example CMA Case",
          description: "This is the summary of example CMA case",
          publication_state: "draft",
          details: {
            "body" => [
              {
                "content_type" => "text/govspeak",
                "content" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case")
              },
            ],
            "metadata" => {
              "bulk_published" => false,
              "document_type" => "cma_case",
              "opened_date" => "2014-01-01",
              "closed_date" => "2015-01-01",
              "case_type" => "ca98-and-civil-cartels",
              "case_state" => "closed",
              "market_sector" => ["energy"],
              "outcome_type" => "ca98-no-grounds-for-action-non-infringement",
            }
          })
      ]
    }

    scenario "displays the metadata" do
      visit "/cma-cases"
      click_link "Example CMA Case"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Example CMA Case")
      expect(page).to have_content("draft")
      expect(page).to have_content("This is the summary of example CMA case")
      expect(page).to have_content("This is the long body of an example CMA case")
      expect(page).to have_content("Opened 2014-01-01")
      expect(page).to have_content("Closed 2015-01-01")
      expect(page).to have_content("Outcome CA98 - no grounds for action")
      expect(page).to have_content("Market sector Energy")
      expect(page).to have_content("Bulk published false")
    end
  end

  scenario "that doesn't exist" do
    content_id = "a-case-that-doesnt-exist"
    publishing_api_does_not_have_item(content_id)

    visit "/cma-cases/#{content_id}"

    expect(page.current_path).to eq("/cma-cases")
    expect(page).to have_content("Document not found")
  end

  context "bulk publishing" do
    let(:cma_cases) {
      [
        FactoryGirl.create(:cma_case,
          title: "Bulk published CMA Case",
          details: {
            "metadata" => {
              "bulk_published" => true,
            }
          })
      ]
    }

    scenario "the document has been bulk published" do
      visit "/cma-cases"
      expect(page).to have_content("Bulk published CMA Case")
      click_link "Bulk published CMA Case"
      expect(page).to have_content("Bulk published true")
    end
  end

  context "attachments" do
    let(:cma_cases) {
      [
        FactoryGirl.create(:cma_case,
          title: "CMA Case without attachments",
          details: { attachments: [] }),
        FactoryGirl.create(:cma_case,
          title: "CMA Case with attachments",
          details: {
            attachments: [
              FactoryGirl.create(:attachment_payload,
                title: 'first attachment',
                created_at: "2015-12-01T10:12:26+00:00",
                updated_at: "2015-12-02T10:12:26+00:00"),
              FactoryGirl.create(:attachment_payload,
                title: 'second attachment',
                created_at: "2015-12-03T10:12:26+00:00",
                updated_at: "2015-12-04T10:12:26+00:00"),
            ]
          }),
      ]
    }

    scenario "Viewing a document without attachments" do
      visit "/cma-cases"
      click_link "CMA Case without attachments"

      expect(page).to have_content("This document doesn’t have any attachments")
    end

    scenario "Viewing a document with attachments" do
      visit "/cma-cases"
      click_link "CMA Case with attachments"

      expect(page).to have_no_content("This document doesn’t have any attachments")
      expect(page).to have_content("2 attachments")

      expect(page).to have_content("first attachment")
      expect(page).to have_content("1 December 2015")
      expect(page).to have_content("2 December 2015")
      expect(page).to have_content("second attachment")
      expect(page).to have_content("3 December 2015")
      expect(page).to have_content("4 December 2015")
    end
  end
end
