Then(/^the CMA case should be in draft$/) do
  assert SpecialistDocumentEdition.last.draft?
end

When(/^I publish the CMA case$/) do
  go_to_edit_page_for_most_recent_case
  publish_document
end

Then(/^the CMA case should be published$/) do
  assert SpecialistDocumentEdition.last.published?
end
