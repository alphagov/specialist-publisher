require "govuk_content_models/test_helpers/factories"

FactoryGirl.define do
  factory :cma_editor, parent: :user do
    organisation_slug "competition-and-markets-authority"
  end

  factory :aaib_editor, parent: :user do
    organisation_slug "air-accidents-investigation-branch"
  end

  factory :generic_editor, parent: :user do
    organisation_slug "ministry-of-tea"
  end

  factory :panopticon_mapping do
    resource_type "specialist-document"
    sequence(:resource_id) { |n| "some-uuid-#{n}"}
    sequence(:panopticon_id) { |n| "some-panopticon-id-#{n}"}
  end

  factory :specialist_document_edition do
    sequence(:slug) {|n| "test-specialist-document-#{n}" }
    sequence(:title) {|n| "Test Specialist Document #{n}" }
    summary "My summary"
    body "My body"
    document_type "cma_case"
    extra_fields do
      {
        opened_date: "2013-04-20",
        market_sector: "some-market-sector",
        case_type: "a-case-type",
        case_state: "open",
      }
    end
  end
end
