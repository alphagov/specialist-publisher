require 'spec_helper'

RSpec.feature "Viewing a specific case", type: :feature do
  let(:fields) { [:base_path, :content_id, :public_updated_at, :title, :publication_state] }
  let(:cma_case_with_attachments) {
    Payloads.cma_case_with_attachments(
      "title" => "CMA Case With Attachment"
    )
  }
  let(:cma_cases) {
    ten_example_cases = 10.times.collect do |n|
      Payloads.cma_case_content_item(
        "title" => "Example CMA Case #{n}",
        "description" => "This is the summary of example CMA case #{n}",
        "base_path" => "/cma-cases/example-cma-case-#{n}",
        "publication_state" => "draft",
      )
    end
    ten_example_cases << cma_case_with_attachments
  }

  let(:page_number) { 1 }
  let(:per_page) { 50 }

  before do
    log_in_as_editor(:cma_editor)

    publishing_api_has_content(cma_cases, document_type: CmaCase.publishing_api_document_type, fields: fields, page: page_number, per_page: per_page)

    cma_cases.each do |cma_case|
      publishing_api_has_item(cma_case)
    end
  end

  scenario "from the index" do
    visit "/cma-cases"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Example CMA Case 0")
    expect(page).to have_content("Example CMA Case 1")
    expect(page).to have_content("Example CMA Case 2")

    click_link "Example CMA Case 0"

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Example CMA Case 0")
    expect(page).to have_content("This is the long body of an example CMA case")
    expect(page).to have_content("This is the summary of example CMA case 0")
    expect(page).to have_content("2014-01-01")
    expect(page).to have_content("CA98 and civil cartels")
    expect(page).to have_content("Energy")
  end

  scenario "that doesn't exist" do
    content_id = "a-case-that-doesnt-exist"
    publishing_api_does_not_have_item(content_id)

    visit "/cma-cases/#{content_id}"

    expect(page.current_path).to eq("/cma-cases")
    expect(page).to have_content("Document not found")
  end

  scenario "Viewing attachments on a document" do
    attachments_payloads = cma_case_with_attachments["details"]["attachments"]

    visit "/cma-cases"
    expect(page).to have_content("Example CMA Case 0")
    expect(page).to have_content("CMA Case With Attachment")

    click_link "Example CMA Case 0"

    expect(page).to have_content("This document doesn’t have any attachments")

    visit "/cma-cases"
    click_link "CMA Case With Attachment"

    expect(page).not_to have_content("This document doesn’t have any attachments")
    expect(page).to have_content(attachments_payloads.length.to_s + " attachments")
    attachments_payloads.each do |attachment|
      expect(page).to have_content(attachment["title"])
      expect(page).to have_content(attachment["created_at"].to_date.to_s(:govuk_date))
      expect(page).to have_content(attachment["updated_at"].to_date.to_s(:govuk_date))
    end
  end
end
