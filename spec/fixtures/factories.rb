FactoryGirl.define do
  factory :user do
   sequence(:uid) { |n| "uid-#{n}"}
   sequence(:name) { |n| "Joe Bloggs #{n}" }
   sequence(:email) { |n| "joe#{n}@bloggs.com" }
    if defined?(GDS::SSO::Config)
      # Grant permission to signin to the app using the gem
      permissions { ["signin"] }
    end
  end

  factory :editor, parent: :user do
    permissions %w(signin editor)
  end

  factory :cma_editor, parent: :user do
    organisation_slug "competition-and-markets-authority"
  end

end
