class VeteransSupportOrganisation < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    veterans_support_organisation_health_and_social_care
    veterans_support_organisation_finance
    veterans_support_organisation_legal_and_justice
    veterans_support_organisation_employment_education_and_training
    veterans_support_organisation_housing
    veterans_support_organisation_families_and_children
    veterans_support_organisation_community_and_social
    veterans_support_organisation_region_england
    veterans_support_organisation_region_northern_ireland
    veterans_support_organisation_region_scotland
    veterans_support_organisation_region_wales
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.title
    "Veterans Support Organisation"
  end

  def primary_publishing_organisation
    "516357f6-92f3-4292-8449-b958e1c63c5f"
  end
end
