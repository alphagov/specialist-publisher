When(/^I create an ESI Fund$/) do
  @document_title = "Example ESI Fund"
  @slug = "european-structural-investment-funds/example-esi-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_esi_fund(@document_fields)
end

Then(/^the ESI Fund has been created$/) do
  check_esi_fund_exists_with(@document_fields)
end

When(/^I create an ESI Fund with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
    closing_date: "2016/01/01",
  }
  create_esi_fund(@document_fields)
end

Then(/^the ESI Fund should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft ESI Fund exists$/) do
  @document_title = "Example ESI Fund"
  @slug = "european-structural-investment-funds/example-esi-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_esi_fund(@document_fields)
end

When(/^I edit an ESI Fund and remove required fields$/) do
  edit_esi_fund(@document_title, summary: "")
end

Then(/^the ESI Fund should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two ESI Funds exist$/) do
  @document_fields = {
    title: "ESI Fund 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }
  create_esi_fund(@document_fields)

  @document_fields = {
    title: "ESI Fund 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }
  create_esi_fund(@document_fields)
end

Then(/^the ESI Funds should be in the publisher CSG index in the correct order$/) do
  visit esi_funds_path

  check_for_documents("ESI Fund 2", "ESI Fund 1")
end

When(/^I edit an ESI Fund$/) do
  @new_title = "Edited Example ESI Fund"
  edit_esi_fund(@document_title, title: @new_title)
end

Then(/^the ESI Fund should have been updated$/) do
  check_for_new_esi_fund_title(@new_title)
end

Then(/^the ESI Fund should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the ESI Fund$/) do
  go_to_show_page_for_esi_fund(@document_title)
  publish_document
end

Then(/^the ESI Fund should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new ESI Fund$/) do
  @document_title = "Example ESI Fund"
  @slug = "european-structural-investment-funds/example-esi-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_esi_fund(@document_fields, publish: true)
end

Given(/^a published ESI Fund exists$/) do
  @document_title = "Example ESI Fund"
  @slug = "european-structural-investment-funds/example-esi-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_esi_fund(@document_fields, publish: true)
end

When(/^I withdraw an ESI Fund$/) do
  withdraw_esi_fund(@document_fields.fetch(:title))
end

Then(/^the ESI Fund should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the ESI Fund edit page$/) do
  go_to_edit_page_for_esi_fund(@document_fields.fetch(:title))
end
