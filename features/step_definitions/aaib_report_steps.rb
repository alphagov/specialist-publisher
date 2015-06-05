When(/^I create a AAIB report$/) do
  @document_title = "Example AAIB Report"
  @slug = "aaib-reports/example-aaib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }

  create_aaib_report(@document_fields)
end

Then(/^the AAIB report has been created$/) do
  check_aaib_report_exists_with(@document_fields)
end

When(/^I create a AAIB report with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
    date_of_occurrence: "Bad data",
  }

  create_aaib_report(@document_fields)
end

Then(/^the AAIB report should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^two AAIB reports exist$/) do
  @document_fields = {
    title: "AAIB Report 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }
  create_aaib_report(@document_fields)

  @document_fields = {
    title: "AAIB Report 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }
  create_aaib_report(@document_fields)
end

Then(/^the AAIB reports should be in the publisher report index in the correct order$/) do
  visit aaib_reports_path

  check_for_documents("AAIB Report 2", "AAIB Report 1")
end

Given(/^a draft AAIB report exists$/) do
  @document_title = "Example AAIB Report"
  @slug = "aaib-reports/example-aaib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }

  create_aaib_report(@document_fields)
end

When(/^I edit a AAIB report$/) do
  @new_title = "Edited Example AAIB Report"
  edit_aaib_report(@document_title, title: @new_title)
end

When(/^I edit an AAIB report and remove required fields$/) do
  edit_aaib_report(@document_title, summary: "")
end

Then(/^the AAIB report should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Then(/^the AAIB report should have been updated$/) do
  check_for_new_aaib_report_title(@new_title)
end

Given(/^there is a published report with an attachment$/) do
  @document_title = "Example AAIB Report"
  @attachment_title = "My attachment"

  @slug = "aaib-reports/example-aaib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }

  create_aaib_report(@document_fields, publish: true)
  add_attachment_to_document(@document_title, @attachment_title)
end

Given(/^a published AAIB report exists$/) do
  @document_title = "Example AAIB Report"
  @slug = "aaib-reports/example-aaib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }

  create_aaib_report(@document_fields, publish: true)
end

When(/^I withdraw a AAIB report$/) do
  withdraw_aaib_report(@document_fields.fetch(:title))
end

Then(/^the AAIB report should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the AAIB report edit page$/) do
  go_to_edit_page_for_aaib_report(@document_fields.fetch(:title))
end

Then(/^the AAIB report should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the AAIB report$/) do
  go_to_show_page_for_aaib_report(@document_title)
  publish_document
end

Then(/^the AAIB report should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new AAIB report$/) do
  @document_title = "Example AAIB Report"
  @slug = "aaib-reports/example-aaib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01"
  }

  create_aaib_report(@document_fields, publish: true)
end
