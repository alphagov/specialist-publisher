Then(/^the CMA case should be in draft$/) do
  expect(
    cma_case_repository.all.last
  ).to be_draft
end

When(/^I publish the CMA case$/) do
  go_to_show_page_for_cma_case(@document_title)
  publish_document
end

Then(/^the CMA case should be published$/) do
  check_document_is_published(@slug, @cma_fields)
end

When(/^I edit the CMA case and republish$/) do
  new_title = "New title"
  @amended_document_attributes = {summary: "New summary", title: new_title }
  edit_cma_case(@document_title, @amended_document_attributes, publish: true)
  @document_title = new_title
end

Then(/^the amended document should be published$/) do
  check_for_published_document_with(@amended_document_attributes)
end

Then(/^previous editions should be archived$/) do
  check_for_correctly_archived_editions(@amended_document_attributes)
end
