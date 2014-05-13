When(/^I create a manual$/) do
  @manual_fields = {
    title: 'Example Manual Title',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
  }

  create_manual(@manual_fields)
end

Then(/^the manual should exist$/) do
  check_manual_exists_with(@manual_fields)
end

Given(/^a draft manual exists$/) do
  @manual_fields = {
    title: 'Example Manual Title',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
  }

  create_manual(@manual_fields)
end

When(/^I edit a manual$/) do
  @new_title = 'Edited Example Manual'
  edit_manual(@manual_fields[:title], title: @new_title)
end

Then(/^the manual should have been updated$/) do
  check_manual_exists_with(@manual_fields.merge(title: @new_title))
end

When(/^I create a manual with an empty title$/) do
  @manual_fields = {
    title: '',
    summary: 'Nullam quis risus eget urna mollis ornare vel eu leo.',
  }

  create_manual(@manual_fields)
end

Then(/^I see errors for the title field$/) do
  check_for_errors_for_fields('title')
end

When(/^I create a document for the manual$/) do
  @document_title = 'Section 1'

  @document_fields = {
    title: @document_title,
    summary: 'Section 1 summary',
    body: 'Section 1 body',
  }

  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

Then(/^I see the manual has the new page$/) do
  visit manuals_path
  click_on @manual_fields.fetch(:title)
  expect(page).to have_content(@document_fields.fetch(:title))
end

Given(/^a draft document exists for the manual$/) do
  @document_title = 'Section 1'

  @document_fields = {
    title: @document_title,
    summary: 'Section 1 summary',
    body: 'Section 1 body',
  }

  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

When(/^I edit the document$/) do
  @new_title = 'A new section title'
  edit_manual_document(
    @manual_fields.fetch(:title),
    @document_fields.fetch(:title),
    title: @new_title,
  )
end

Then(/^the document should have been updated$/) do
  check_manual_document_exists_with(
    @manual_fields.fetch(:title),
    title: @new_title,
  )
end
