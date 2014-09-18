require "document_republisher"

Given(/^some published and draft specialist documents exist$/) do
  stub_panopticon
  stub_rummager
  stub_delivery_api

  seed_cases(1, state: "draft")
  @published_documents = seed_cases(2, state: "published")

  reset_panopticon_stubs_and_messages
  reset_rummager_stubs_and_messages
end

Given(/^their RenderedSpecialistDocument records are missing$/) do
  destroy_all_rendered_specialist_document_records
end

When(/^I republish published documents$/) do
  repositories_and_listeners = [
    OpenStruct.new(
      repository: cma_case_repository,
      observers: CmaCaseObserversRegistry.new.publication,
    )
  ]

  DocumentRepublisher.new(repositories_and_listeners).republish!
end

Then(/^the documents should be republished with valid RenderedSpecialistDocuments$/) do
  check_all_published_documents_have_valid_rendered_specialist_documents

  @published_documents.each do |document|
    attrs = document.attributes.slice(:title, :summary, :body, :opened_date)
    check_document_was_republished(document.slug, attrs)
  end
end
