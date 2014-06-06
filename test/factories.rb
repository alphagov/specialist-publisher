require 'govuk_content_models/test_helpers/factories'

FactoryGirl.define do
  factory :cma_editor, parent: :user do
    organisation_slug 'competition-and-markets-authority'
  end
end

FactoryGirl.define do
  factory :generic_editor, parent: :user do
    organisation_slug 'ministry-of-tea'
  end
end

FactoryGirl.define do
  factory :panopticon_mapping do
    resource_type "specialist-document"
    sequence(:resource_id) { |n| "some-uuid-#{n}"}
    sequence(:panopticon_id) { |n| "some-panopticon-id-#{n}"}
  end
end
