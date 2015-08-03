When(/^I create a International Development Fund$/) do
  @document_title = "Example International Development Fund"
  @slug = "international-development-funding/example-international-development-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_international_development_fund(@document_fields)
end

Then(/^the International Development Fund has been created$/) do
  check_international_development_fund_exists_with(@document_fields)
end

When(/^I create a International Development Fund with invalid fields$/) do
  @document_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }
  create_international_development_fund(@document_fields)
end

Then(/^the International Development Fund should not have been created$/) do
  check_document_does_not_exist_with(@document_fields)
end

Given(/^a draft International Development Fund exists$/) do
  @document_title = "Example International Development Fund"
  @slug = "international-development-funding/example-international-development-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_international_development_fund(@document_fields)
end

When(/^I edit an International Development Fund and remove required fields$/) do
  edit_international_development_fund(@document_title, summary: "")
end

Then(/^the International Development Fund should not have been updated$/) do
  expect(page).to have_content("Summary can't be blank")
end

Given(/^two International Development Funds exist$/) do
  @document_fields = {
    title: "International Development Fund 1",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }
  create_international_development_fund(@document_fields)

  @document_fields = {
    title: "International Development Fund 2",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }
  create_international_development_fund(@document_fields)
end

Then(/^the International Development Funds should be in the publisher IDF index in the correct order$/) do
  visit international_development_funds_path

  check_for_documents("International Development Fund 2", "International Development Fund 1")
end

When(/^I edit a International Development Fund$/) do
  @new_title = "Edited Example International Development Fund"
  edit_international_development_fund(@document_title, title: @new_title)
end

Then(/^the International Development Fund should have been updated$/) do
  check_for_new_international_development_fund_title(@new_title)
end

Then(/^the International Development Fund should be in draft$/) do
  expect(page).to have_content("Publication state draft")
end

When(/^I publish the International Development Fund$/) do
  go_to_show_page_for_international_development_fund(@document_title)
  publish_document
end

Then(/^the International Development Fund should be published$/) do
  check_document_is_published(@slug, @document_fields)
end

When(/^I publish a new International Development Fund$/) do
  @document_title = "Example International Development Fund"
  @slug = "international-development-funding/example-international-development-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_international_development_fund(@document_fields, publish: true)
end

Given(/^a published International Development Fund exists$/) do
  @document_title = "Example International Development Fund"
  @slug = "international-development-funding/example-international-development-fund"
  @document_fields = {
    title: @document_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: document_body,
  }

  create_international_development_fund(@document_fields, publish: true)
end

When(/^I withdraw a International Development Fund$/) do
  withdraw_international_development_fund(@document_fields.fetch(:title))
end

Then(/^the International Development Fund should be withdrawn$/) do
  check_document_is_withdrawn(@slug, @document_fields.fetch(:title))
end

When(/^I am on the International Development Fund edit page$/) do
  go_to_edit_page_for_international_development_fund(@document_fields.fetch(:title))
end
