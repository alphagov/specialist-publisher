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
    title: @document_title,
    summary: "Section 1 summary",
    body: "Section 1 body",
  }

  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

Then(/^I see the manual has the new section$/) do
  visit manuals_path
  click_on @manual_fields.fetch(:title)
  expect(page).to have_content(@document_fields.fetch(:title))
end

Then(/^the manual section slug should be reserved$/) do
  check_manual_document_slug_was_reserved(@document_slug)
end

Given(/^a draft document exists for the manual$/) do
  @document_title = "Section 1"
  @document_slug = "guidance/example-manual-title/section-1"

  @document_fields = {
    title: @document_title,
    summary: "Section 1 summary",
    body: "Section 1 body",
  }

  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

When(/^I edit the document$/) do
  @new_title = "A new section title"
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

When(/^I visit the specialist documents path for the manual document$/) do
  link = page.find("a", text: @document_title)
  document_id = URI.parse(link["href"]).path.split("/").last
  visit specialist_document_path(document_id)
end

Then(/^the document is not found$/) do
  expect(page).to have_content("Document not found")
end

Then(/^the manual's documents won't have changed$/) do
  expect(page).to have_content(@document_fields.fetch(:title))
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
  check_manual_and_documents_were_published(
    @manual_slug,
    @manual_fields,
    @document_slug,
    @document_fields,
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
    title: @document_title,
    summary: "Section 1 summary",
    body: "Section 1 body",
  }

  create_manual_document(@manual_title, @document_fields)

  publish_manual
end

When(/^I edit the manual's documents$/) do
  @updated_document_fields = {
    summary: "Updated section",
    body: "Updated section",
  }

  @document_fields = @document_fields.merge(@updated_document_fields)

  edit_manual_document(@manual_title, @document_title, @updated_document_fields)
end

When(/^I start creating a new manual document$/) do
  @document_fields = {
    title: "Section 1",
    summary: "Section 1 summary",
    body: "Section 1 body",
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
    title: "Section 1",
    summary: "Section 1 summary",
    body: "Section 1 body",
  }

  go_to_manual_page(@manual_fields[:title])
  click_on "Add Section"
  fill_in_fields(@document_fields)
end

Then(/^I see the document body preview$/) do
  check_for_document_body_preview("Section 1 body")
end

When(/^I copy\+paste the embed code into the body of the document$/) do
  copy_embed_code_for_attachment_and_paste_into_manual_document_body("My attachment")
end
