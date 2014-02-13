require 'govuk_content_models/test_helpers/factories'

FactoryGirl.define do
  factory :cma_editor, parent: :user do
    organisation_slug 'competition-and-markets-authority'
  end
end

FactoryGirl.define do
  factory :specialist_document_artefact, parent: :artefact do
    sequence(:slug) { |n| "example-finder/artefact-#{n}"}
    kind 'specialist-document'
    owning_app 'specialist-document-publisher'
  end
end
