FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "Winston #{n}"}
    permissions { ["signin"] }
  end

  factory :cma_editor, parent: :user do
    organisation_slug 'competition-and-markets-authority'
  end
end
