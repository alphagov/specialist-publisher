require "govuk_content_models/test_helpers/factories"

FactoryGirl.define do
  factory :editor, parent: :user do
    permissions %w(signin editor)
  end

  factory :cma_writer, parent: :user do
    organisation_slug "competition-and-markets-authority"
  end

  factory :cma_editor, parent: :editor do
    organisation_slug "competition-and-markets-authority"
  end

  factory :aaib_editor, parent: :editor do
    organisation_slug "air-accidents-investigation-branch"
  end

  factory :ast_editor, parent: :editor do
    organisation_slug "first-tier-tribunal-asylum-support"
  end

  factory :dclg_editor, parent: :editor do
    organisation_slug "department-for-communities-and-local-government"
  end

  factory :defra_editor, parent: :editor do
    organisation_slug "department-for-environment-food-rural-affairs"
  end

  factory :dfid_editor, parent: :editor do
    organisation_slug "department-for-international-development"
  end

  factory :maib_editor, parent: :editor do
    organisation_slug "marine-accident-investigation-branch"
  end

  factory :mhra_editor, parent: :editor do
    organisation_slug "medicines-and-healthcare-products-regulatory-agency"
  end

  factory :ne_editor, parent: :editor do
    organisation_slug "natural-england"
  end

  factory :raib_editor, parent: :editor do
    organisation_slug "rail-accident-investigation-branch"
  end

  factory :dvsa_editor, parent: :editor do
    organisation_slug "driver-and-vehicle-standards-agency"
  end

  factory :utaac_editor, parent: :editor do
    organisation_slug "upper-tribunal-administrative-appeals-chamber"
  end

  factory :taxtribunal_editor, parent: :editor do
    organisation_slug "upper-tribunal-tax-and-chancery-chamber"
  end

  factory :employmentappealtribunal_editor, parent: :editor do
    organisation_slug "employment-appeal-tribunal"
  end

  factory :employmenttribunal_editor, parent: :editor do
    organisation_slug "employment-tribunal"
  end

  factory :generic_writer, parent: :user do
    organisation_slug "ministry-of-tea"
  end

  factory :generic_editor, parent: :editor do
    organisation_slug "ministry-of-tea"
  end

  factory :gds_editor, parent: :user do
    permissions %w(signin gds_editor)
    organisation_slug "government-digital-service"
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
