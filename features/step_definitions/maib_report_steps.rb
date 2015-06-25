When(/^I create a MAIB report$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@document_fields)
end

Then(/^the MAIB report has been created$/) do
  check_maib_report_exists_with(@document_fields)
end

When(/^I create a MAIB report with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
    date_of_occurrence: "Bad data",
  }
  create_maib_report(@document_fields)
end

Then(/^the MAIB report should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft MAIB report exists$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@document_fields)
end

When(/^I edit an MAIB report and remove required fields$/) do
  edit_maib_report(@document_title, summary: "")
end

Then(/^the MAIB report should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two MAIB reports exist$/) do
  @document_fields = {
    title: "MAIB report 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_maib_report(@document_fields)

  @document_fields = {
    title: "MAIB report 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_maib_report(@document_fields)
end

Then(/^the MAIB reports should be in the publisher report index in the correct order$/) do
  visit maib_reports_path

  check_for_documents("MAIB report 2", "MAIB report 1")
end

When(/^I edit a MAIB report$/) do
  @new_title = "Edited Example MAIB report"
  edit_maib_report(@document_title, title: @new_title)
end

Then(/^the MAIB report should have been updated$/) do
  check_for_new_maib_report_title(@new_title)
end

Then(/^the MAIB report should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the MAIB report$/) do
  go_to_show_page_for_maib_report(@document_title)
  publish_document
end

Then(/^the MAIB report should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new MAIB report$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@document_fields, publish: true)
end

Given(/^a published MAIB report exists$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@document_fields, publish: true)
end

When(/^I withdraw a MAIB report$/) do
  withdraw_maib_report(@document_fields.fetch(:title))
end

Then(/^the MAIB report should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the MAIB report edit page$/) do
  go_to_edit_page_for_maib_report(@document_title)
end
