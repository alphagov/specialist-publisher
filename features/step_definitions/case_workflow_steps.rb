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
  check_cma_case_is_published(@cma_fields.fetch(:title))
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

When(/^I edit it and republish$/) do
  @amended_document_attributes = {summary: "New summary", title: "My title"}
  edit_cma_case(@amended_document_attributes, publish: true)
end

Then(/^the amended CMA case should be published$/) do
  published_doc = RenderedSpecialistDocument.where(title: @amended_document_attributes.fetch(:title)).last

  @amended_document_attributes.each do |attribute, expected_value|
    expect(published_doc.public_send(attribute)).to eq(expected_value)
  end
end
