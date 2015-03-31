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
  visit cma_case_path(document_id)
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

Then(/^change notes for the original section are not duplicated$/) do
  # There were no changes to the original section, so there should only be a single change note.
  check_manual_section_has_no_duplicated_change_notes(@manual_slug, @original_document_slug)
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

  # Clear out any remote requests caught by webmock.
  # We don't want the remote calls that were made during the publishing setup
  # to interfere with later webmock assertions.
  reset_remote_requests
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
  click_on("Edit section")

  @change_note = "Changed title for the purposes of testing."

  fields = {
    section_title: "This document has changed for the purposes of testing",
    change_note: @change_note,
  }

  save_document
  edit_manual_document(@manual_title, @document_title, fields)
end

When(/^I re\-publish the section$/) do
  publish_manual
end

When(/^I edit the manual document without a change note$/) do
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
  @original_document_slug = @document_slug
  @document_slug = [@manual_slug, "section-2"].join("/")
  @document_fields = {
    section_title: @document_title,
    section_summary: "Section 2 summary",
    section_body: "Section 2 body",
  }

  create_manual_document(@manual_title, @document_fields)
end

Then(/^I see no visible change note in the manual document edit form$/) do
  check_change_note_value(@manual_title, @document_title, "")
end

When(/^I add invalid HTML to the document body$/) do
  fill_in :body, with: "<script>alert('naughty naughty');</script>"
end

When(/^I create another manual with the same slug$/) do
  create_manual(@manual_fields)
end

When(/^I create a section with duplicate title$/) do
  create_manual_document(@manual_fields.fetch(:title), @document_fields)
end

Then(/^the manual and its documents have failed to publish$/) do
  expect(page).to have_content("This manual was sent for publishing")
  expect(page).to have_content("something went wrong. Our team has been notified.")
end

Then(/^the manual and its documents are queued for publishing$/) do
  expect(page).to have_content("This manual was sent for publishing")
  expect(page).to have_content("It should be published shortly.")
end

Given(/^a recoverable error occurs$/) do
  mock_panopticon_http_server_error
end

Given(/^an unrecoverable error occurs$/) do
  mock_panopticon_http_client_error
end

Given(/^a version mismatch occurs$/) do
  PublishManualService.any_instance.stub(:versions_match?).and_return(false)
end

When(/^I publish the manual expecting a recoverable error$/) do
  begin
    publish_manual
  rescue PublishManualWorker::FailedToPublishError => e
    @error = e
  end
end

Then(/^the publication reattempted$/) do
  # This is merely to assure that the correct error type is raised forcing
  # sidekiq to retry. This is the default behaviour of sidekiq in the case of a failure
  expect(@error).to be_a(PublishManualWorker::FailedToPublishError)
end

When(/^I make changes and preview the manual$/) do
  change_manual_without_saving(
    @manual_title,
    title: "Title for preview",
    body: "Body for preview",
  )
  generate_preview
end

When(/^I start creating a new manual$/) do
  @manual_title = "Original Manual title"

  @manual_fields = {
    title: @manual_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
    body: "Body for preview",
  }

  create_manual(@manual_fields, save: false)
end

When(/^I preview the manual$/) do
  generate_preview
end

Then(/^I see the manual body preview$/) do
  check_for_manual_body_preview
end

When(/^I start creating a new manual with embedded javascript$/) do
  @manual_fields = {
    body: "<script>alert('Oh noes!)</script>",
  }

  create_manual(@manual_fields, save: false)
end

Then(/^I see a warning about section slug clash at publication$/) do
  check_for_clashing_section_slugs
end

Given(/^a published manual with at least two sections exists$/) do
  @manual_title = "Example Manual Title"
  @manual_slug = "guidance/example-manual-title"

  @manual_fields = {
    title: @manual_title,
    summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
  }

  create_manual(@manual_fields)

  @section_titles = []
  @section_slugs = []

  (1..3).each do |section_number|
    section_title = "Section #{section_number}"
    section_slug = [@manual_slug, "section-#{section_number}"].join("/")
    section_fields = {
      section_title: section_title,
      section_summary: "Section #{section_number} summary",
      section_body: "Section #{section_number} body",
    }

    create_manual_document(@manual_title, section_fields)

    @section_titles << section_title
    @section_slugs << section_slug
  end

  publish_manual

  # Clear out any remote requests caught by webmock.
  # We don't want the remote calls that were made during the publishing setup
  # to interfere with later webmock assertions.
  reset_remote_requests
end

When(/^a DevOps specialist withdraws the manual for me$/) do
  withdraw_manual(@manual_title)
end

Then(/^the manual should be withdrawn$/) do
  check_manual_is_withdrawn(@manual_title, @manual_slug, @section_titles, @section_slugs)
end
