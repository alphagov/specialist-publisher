Then(/^the CMA case should be in draft$/) do
  expect(
    SpecialistPublisherWiring.get(:specialist_document_registry).all.last
  ).to be_draft
end

When(/^I publish the CMA case$/) do
  go_to_edit_page_for_most_recent_case
  publish_document
end

Then(/^the CMA case should be published$/) do
  expect(
    SpecialistPublisherWiring.get(:specialist_document_registry).all.last
  ).to be_published
end
