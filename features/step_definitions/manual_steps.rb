When(/^I create a manual$/) do
  @manual_fields = {
    title: "Example Manual Title",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }
  @manual_slug = "guidance/example-manual-title"

  create_manual(@manual_fields)
end

Then(/^the manual should exist$/) do
  check_manual_exists_with(@manual_fields)
end

Then(/^the manual slug should be reserved$/) do
  check_manual_slug_was_reserved(@manual_slug)
end

Given(/^a draft manual exists$/) do
  @manual_slug = "guidance/example-manual-title"
  @manual_title = "Example Manual Title"

  @manual_fields = {
    title: "Example Manual Title",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }

  create_manual(@manual_fields)
end

When(/^I edit a manual$/) do
  @new_title = "Edited Example Manual"
  edit_manual(@manual_fields[:title], title: @new_title)
end

Then(/^the manual should have been updated$/) do
  check_manual_exists_with(@manual_fields.merge(title: @new_title))
end

When(/^I create a manual with an empty title$/) do
  @manual_fields = {
    title: "",
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }

  create_manual(@manual_fields)
end

Then(/^I see errors for the title field$/) do
  check_for_errors_for_fields("title")
end

When(/^I create a document for the manual$/) do
  @document_title = "Section 1"
  @document_slug = [@manual_slug, "section-1"].join("/")

  @document_fields = {
    section_title: @document_title,
    section_summary: "Section 1 summary",
    section_body: "Section 1 body",
  }

  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

Then(/^I see the manual has the new section$/) do
  visit manuals_path
  click_on @manual_fields.fetch(:title)
  expect(page).to have_content(@document_fields.fetch(:section_title))
end

Then(/^the manual section slug should be reserved$/) do
  check_manual_document_slug_was_reserved(@document_slug)
end

Given(/^a draft document exists for the manual$/) do
  @document_title = "Section 1"
  @document_slug = "guidance/example-manual-title/section-1"

  @document_fields = {
    section_title: @document_title,
    section_summary: "Section 1 summary",
    section_body: "Section 1 body",
  }

  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

When(/^I edit the document$/) do
  @new_title = "A new section title"
  edit_manual_document(
    @manual_fields.fetch(:title),
    @document_fields.fetch(:section_title),
    section_title: @new_title,
  )
end

Then(/^the document should have been updated$/) do
  check_manual_document_exists_with(
    @manual_fields.fetch(:title),
    section_title: @new_title,
  )
end

When(/^I visit the specialist documents path for the manual document$/) do
  link = page.find("a", text: @document_title)
  document_id = URI.parse(link["href"]).path.split("/").last
  visit specialist_document_path(document_id)
end

Then(/^the document is not found$/) do
  expect(page).to have_content("Document not found")
end

Then(/^the manual's documents won't have changed$/) do
  expect(page).to have_content(@document_fields.fetch(:section_title))
end

When(/^I create a document with empty fields$/) do
  create_manual_document(@manual_fields.fetch(:title), {})
end

Then(/^I see errors for the document fields$/) do
  %w(Title Summary Body).each do |field|
    expect(page).to have_content("#{field} can't be blank")
  end
  expect(page).not_to have_content("Add attachment")
end

When(/^I publish the manual$/) do
  publish_manual
end

Then(/^the manual and its documents are published$/) do
  document_attributes = {
    title: @document_fields[:section_title],
    summary: @document_fields[:section_summary],
    body: @document_fields[:section_body],
  }

  check_manual_and_documents_were_published(
    @manual_slug,
    @manual_fields,
    @document_slug,
    document_attributes,
  )
end

Given(/^a published manual exists$/) do
  @manual_title = "Example Manual Title"
  @manual_slug = "guidance/example-manual-title"

  @manual_fields = {
    title: @manual_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }

  create_manual(@manual_fields)

  @document_title = "Section 1"
  @document_slug = [@manual_slug, "section-1"].join("/")
  @document_fields = {
    section_title: @document_title,
    section_summary: "Section 1 summary",
    section_body: "Section 1 body",
  }

  create_manual_document(@manual_title, @document_fields)

  publish_manual
end

When(/^I edit the manual's documents$/) do
  @updated_document_fields = {
    section_summary: "Updated section",
    section_body: "Updated section",
    change_note: "Updated section",
  }

  @document_fields = @document_fields.merge(@updated_document_fields)

  edit_manual_document(@manual_title, @document_title, @updated_document_fields)
end

When(/^I start creating a new manual document$/) do
  @document_fields = {
    section_title: "Section 1",
    section_summary: "Section 1 summary",
    section_body: "Section 1 body",
  }

  create_manual_document_for_preview(
    @document_fields.fetch(:title),
    @document_fields,
  )
end

When(/^I preview the document$/) do
  generate_preview
end

When(/^I create a document to preview$/) do
  @document_fields = {
    section_title: "Section 1",
    section_summary: "Section 1 summary",
    section_body: "Section 1 body",
  }

  go_to_manual_page(@manual_fields[:title])
  click_on "Add section"
  fill_in_fields(@document_fields)
end

Then(/^I see the document body preview$/) do
  check_for_document_body_preview("Section 1 body")
end

When(/^I copy\+paste the embed code into the body of the document$/) do
  copy_embed_code_for_attachment_and_paste_into_manual_document_body("My attachment")
end

When(/^I create a new draft of a section with a change note$/) do
  click_on(@document_title)
  click_on("Edit Section")

  @change_note = "Changed title for the purposes of testing."

  fields = {
    section_title: "This document has changed for the purposes of testing",
    change_note: @change_note,
  }

  save_document
  edit_manual_document(@manual_title, @document_title, fields)
end

When(/^I re\-publish the section$/) do
  publish_document
end

Then(/^the change note is also published$/) do
  check_manual_change_note_exported(@manual_slug, @change_note)
  check_manual_change_note_artefact_was_created(@manual_slug)
end

When(/^I edit the document without a change note$/) do
  @updated_document_fields = {
    section_summary: "Updated section",
    section_body: "Updated section",
    change_note: "",
  }

  @document_fields = @document_fields.merge(@updated_document_fields)

  edit_manual_document(@manual_title, @document_title, @updated_document_fields)
end

Then(/^I see an error requesting that I provide a change note$/) do
  expect(page).to have_content("You must provide a change note or indicate minor update")
end

When(/^I indicate that the change is minor$/) do
  check("Minor update")
  save_document
end

Then(/^the document is updated without a change note$/) do
  check_manual_document_exists_with(
    @manual_title,
    section_title: @document_title,
    section_summary: @updated_document_fields.fetch(:section_summary),
  )
end

When(/^I add another section to the manual$/) do
  @document_title = "Section 2"
  @document_slug = [@manual_slug, "section-2"].join("/")
  @document_fields = {
    section_title: @document_title,
    section_summary: "Section 2 summary",
    section_body: "Section 2 body",
  }

  create_manual_document(@manual_title, @document_fields)
end
