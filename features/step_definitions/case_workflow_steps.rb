Then(/^the CMA case should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the CMA case$/) do
  go_to_show_page_for_cma_case(@document_title)
  publish_document
end

Then(/^the CMA case should be published$/) do
  market_sectors = Array(@document_fields.fetch(:market_sector, nil))

  expected_fields = @document_fields.merge(
    market_sector: market_sectors.map(&:downcase),
  )

  check_document_is_published(@slug, expected_fields)
end

When(/^I edit the CMA case and republish$/) do
  new_title = "New title"
  @amended_document_attributes = {summary: "New summary", title: new_title }
  edit_cma_case(@document_title, @amended_document_attributes, minor_update: true, publish: true)
  @document_title = new_title
end

Then(/^the amended document should be published$/) do
  check_document_was_republished(@slug, @amended_document_attributes)
end

Then(/^previous editions should be archived$/) do
  check_for_correctly_archived_editions(@amended_document_attributes)
end

Then(/^I should be unable to publish the document$/) do
  check_document_cant_be_published
end
