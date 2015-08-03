When(/^I create a Countryside Stewardship Grant$/) do
  @document_title = "Example Countryside Stewardship Grant"
  @slug = "countryside-stewardship-grants/example-countryside-stewardship-grant"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_countryside_stewardship_grant(@document_fields)
end

Then(/^the Countryside Stewardship Grant has been created$/) do
  check_countryside_stewardship_grant_exists_with(@document_fields)
end

When(/^I create a Countryside Stewardship Grant with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }
  create_countryside_stewardship_grant(@document_fields)
end

Then(/^the Countryside Stewardship Grant should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft Countryside Stewardship Grant exists$/) do
  @document_title = "Example Countryside Stewardship Grant"
  @slug = "countryside-stewardship-grants/example-countryside-stewardship-grant"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_countryside_stewardship_grant(@document_fields)
end

When(/^I edit an Countryside Stewardship Grant and remove required fields$/) do
  edit_countryside_stewardship_grant(@document_title, summary: "")
end

Then(/^the Countryside Stewardship Grant should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two Countryside Stewardship Grants exist$/) do
  @document_fields = {
    title: "Countryside Stewardship Grant 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }
  create_countryside_stewardship_grant(@document_fields)

  @document_fields = {
    title: "Countryside Stewardship Grant 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }
  create_countryside_stewardship_grant(@document_fields)
end

Then(/^the Countryside Stewardship Grants should be in the publisher CSG index in the correct order$/) do
  visit countryside_stewardship_grants_path

  check_for_documents("Countryside Stewardship Grant 2", "Countryside Stewardship Grant 1")
end

When(/^I edit a Countryside Stewardship Grant$/) do
  @new_title = "Edited Example Countryside Stewardship Grant"
  edit_countryside_stewardship_grant(@document_title, title: @new_title)
end

Then(/^the Countryside Stewardship Grant should have been updated$/) do
  check_for_new_countryside_stewardship_grant_title(@new_title)
end

Then(/^the Countryside Stewardship Grant should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the Countryside Stewardship Grant$/) do
  go_to_show_page_for_countryside_stewardship_grant(@document_title)
  publish_document
end

Then(/^the Countryside Stewardship Grant should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new Countryside Stewardship Grant$/) do
  @document_title = "Example Countryside Stewardship Grant"
  @slug = "countryside-stewardship-grants/example-countryside-stewardship-grant"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_countryside_stewardship_grant(@document_fields, publish: true)
end

Given(/^a published Countryside Stewardship Grant exists$/) do
  @document_title = "Example Countryside Stewardship Grant"
  @slug = "countryside-stewardship-grants/example-countryside-stewardship-grant"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_countryside_stewardship_grant(@document_fields, publish: true)
end

When(/^I withdraw a Countryside Stewardship Grant$/) do
  withdraw_countryside_stewardship_grant(@document_fields.fetch(:title))
end

Then(/^the Countryside Stewardship Grant should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the Countryside Stewardship Grant edit page$/) do
  go_to_edit_page_for_countryside_stewardship_grant(@document_fields.fetch(:title))
end
