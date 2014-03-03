Then(/^the CMA case should be in draft$/) do
  expect(
    specialist_document_repository.all.last
  ).to be_draft
end

When(/^I publish the CMA case$/) do
  go_to_edit_page_for_most_recent_case
  publish_document
end

Then(/^the CMA case should be published$/) do
  expect(
    specialist_document_repository.all.last
  ).to be_published
end

When(/^I attempt to publish a new CMA case without a title$/) do
  @cma_fields = {
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
    body: ('Praesent commodo cursus magna, vel scelerisque nisl consectetur et.' * 10),
    opened_date: '2014-01-01'
  }

  create_cma_case(@cma_fields, publish: true)
end

Then(/^I should see the editing form again with an error about the missing title$/) do
  check_for_missing_title_error
end
