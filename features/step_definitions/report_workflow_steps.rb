Then(/^the AAIB report should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the AAIB report$/) do
  go_to_show_page_for_aaib_report(@document_title)
  publish_document
end

Then(/^the AAIB report should be published$/) do
  check_document_is_published(@slug, @aaib_fields)
end

When(/^I publish a new AAIB report$/) do
  @document_title = "Example AAIB Report"
  @slug = "aaib-reports/example-aaib-report"
  @aaib_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }

  create_aaib_report(@aaib_fields, publish: true)
end

When(/^I edit the AAIB report and republish$/) do
  @amended_document_attributes = {summary: "New summary", title: "My title"}
  edit_aaib_report(@document_title, @amended_document_attributes, publish: true)
end
