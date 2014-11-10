When(/^I create a RAIB report$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @raib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@raib_report_fields)
end

Then(/^the RAIB report has been created$/) do
  check_raib_report_exists_with(@raib_report_fields)
end

When(/^I create a RAIB report with invalid fields$/) do
  @raib_report_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }
  create_raib_report(@raib_report_fields)
end

Then(/^the RAIB report should not have been created$/) do
  check_document_does_not_exist_with(@raib_report_fields)
end

Given(/^a draft RAIB report exists$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @raib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@raib_report_fields)
end

When(/^I edit an RAIB report and remove required fields$/) do
  edit_raib_report(@document_title, summary: "")
end

Then(/^the RAIB report should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two RAIB reports exist$/) do
  @raib_report_fields = {
    title: "RAIB report 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_raib_report(@raib_report_fields)

  @raib_report_fields = {
    title: "RAIB report 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_raib_report(@raib_report_fields)
end

Then(/^the RAIB reports should be in the publisher IDF index in the correct order$/) do
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
  check_document_is_published(@slug, @raib_report_fields)
end

When(/^I publish a new RAIB report$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @raib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@raib_report_fields, publish: true)
end

When(/^I edit the RAIB report and republish$/) do
  @amended_document_attributes = {summary: "New summary", title: "My title"}
  edit_raib_report(@document_title, @amended_document_attributes, publish: true)
end

Given(/^a published RAIB report exists$/) do
  @document_title = "Example RAIB report"
  @slug = "raib-reports/example-raib-report"
  @raib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_raib_report(@raib_report_fields, publish: true)
end

When(/^I withdraw a RAIB report$/) do
  withdraw_raib_report(@raib_report_fields.fetch(:title))
end

Then(/^the RAIB report should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @raib_report_fields.fetch(:title))
end

When(/^I edit the RAIB report and indicate the change is minor$/) do
  @updated_document_fields = {
    body: "Updated body",
  }

  @raib_report_fields = @raib_report_fields.merge(@updated_document_fields)

  go_to_edit_page_for_raib_report(@raib_report_fields[:title])

  fill_in "Body", with: @updated_document_fields[:body]
  check "Minor update"

  save_document
end
