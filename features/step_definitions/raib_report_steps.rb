When(/^I create a RAIB report$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@document_fields)
end

Then(/^the RAIB report has been created$/) do
  check_raib_report_exists_with(@document_fields)
end

When(/^I create a RAIB report with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
    date_of_occurrence: "Bad data",
  }
  create_raib_report(@document_fields)
end

Then(/^the RAIB report should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft RAIB report exists$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@document_fields)
end

When(/^I edit an RAIB report and remove required fields$/) do
  edit_raib_report(@document_title, summary: "")
end

Then(/^the RAIB report should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two RAIB reports exist$/) do
  @document_fields = {
    title: "RAIB report 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_raib_report(@document_fields)

  @document_fields = {
    title: "RAIB report 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_raib_report(@document_fields)
end

Then(/^the RAIB reports should be in the publisher report index in the correct order$/) do
  visit raib_reports_path

  check_for_documents("RAIB report 2", "RAIB report 1")
end

When(/^I edit a RAIB report$/) do
  @new_title = "Edited Example RAIB report"
  edit_raib_report(@document_title, title: @new_title)
end

Then(/^the RAIB report should have been updated$/) do
  check_for_new_raib_report_title(@new_title)
end

Then(/^the RAIB report should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the RAIB report$/) do
  go_to_show_page_for_raib_report(@document_title)
  publish_document
end

Then(/^the RAIB report should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new RAIB report$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@document_fields, publish: true)
end

Given(/^a published RAIB report exists$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@document_fields, publish: true)
end

When(/^I withdraw a RAIB report$/) do
  withdraw_raib_report(@document_fields.fetch(:title))
end

Then(/^the RAIB report should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the RAIB report edit page$/) do
  go_to_edit_page_for_raib_report(@document_fields.fetch(:title))
end
