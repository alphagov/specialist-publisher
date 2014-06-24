Then(/^the CMA case should be in draft$/) do
  expect(
    specialist_document_repository.all.last
  ).to be_draft
end

When(/^I publish the CMA case$/) do
  go_to_show_page_for_document(@document_title)
  publish_document
end

Then(/^the CMA case should be published$/) do
  check_cma_case_is_published(@slug, @cma_fields.fetch(:title))
end

When(/^I edit it and republish$/) do
  @amended_document_attributes = {summary: "New summary", title: "My title"}
  edit_document(@document_title, @amended_document_attributes, publish: true)
end

Then(/^the amended CMA case should be published$/) do
  check_for_published_document_with(@amended_document_attributes)
end

Then(/^previous editions should be archived$/) do
  check_for_correctly_archived_editions(@amended_document_attributes)
end
