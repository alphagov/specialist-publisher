When(/^I create a MAIB report$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @maib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@maib_report_fields)
end

Then(/^the MAIB report has been created$/) do
  check_maib_report_exists_with(@maib_report_fields)
end

When(/^I create a MAIB report with invalid fields$/) do
  @maib_report_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }
  create_maib_report(@maib_report_fields)
end

Then(/^the MAIB report should not have been created$/) do
  check_document_does_not_exist_with(@maib_report_fields)
end

Given(/^a draft MAIB report exists$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @maib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@maib_report_fields)
end

When(/^I edit an MAIB report and remove required fields$/) do
  edit_maib_report(@document_title, summary: "")
end

Then(/^the MAIB report should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two MAIB reports exist$/) do
  @maib_report_fields = {
    title: "MAIB report 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_maib_report(@maib_report_fields)

  @maib_report_fields = {
    title: "MAIB report 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }
  create_maib_report(@maib_report_fields)
end

Then(/^the MAIB reports should be in the publisher IDF index in the correct order$/) do
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
  check_document_is_published(@slug, @maib_report_fields)
end

When(/^I publish a new MAIB report$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @maib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@maib_report_fields, publish: true)
end

When(/^I edit the MAIB report and republish$/) do
  @amended_document_attributes = {summary: "New summary", title: "My title"}
  edit_maib_report(@document_title, @amended_document_attributes, publish: true)
end

Given(/^a published MAIB report exists$/) do
  @document_title = "Example MAIB report"
  @slug = "maib-reports/example-maib-report"
  @maib_report_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
    date_of_occurrence: "2014-01-01",
  }

  create_maib_report(@maib_report_fields, publish: true)
end

When(/^I withdraw a MAIB report$/) do
  withdraw_maib_report(@maib_report_fields.fetch(:title))
end

Then(/^the MAIB report should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @maib_report_fields.fetch(:title))
end

When(/^I edit the MAIB report and indicate the change is minor$/) do
  @updated_document_fields = {
    body: "Updated section",
  }

  @maib_report_fields = @maib_report_fields.merge(@updated_document_fields)

  go_to_edit_page_for_maib_report(@document_title)

  fill_in "Body", with: @updated_document_fields[:body]
  check "Minor update"

  save_document
end
