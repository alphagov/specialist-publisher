class UkMarketConformityAssessmentBody < Document
  # validates :updated_at, presence: true, date: true
  # validates :uk_market_conformity_assessment_body_number, presence: true
  # validates :uk_market_conformity_assessment_body_type, presence: true
  # validates :uk_market_conformity_assessment_body_registered_office_location, presence: true
  # validates :uk_market_conformity_assessment_body_testing_locations, presence: true
  # validates :uk_market_conformity_assessment_body_website, presence: true
  # validates :uk_market_conformity_assessment_body_email, presence: true
  # validates :uk_market_conformity_assessment_body_phone, presence: true
  # validates :uk_market_conformity_assessment_body_legislative_area, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    updated_at
    uk_market_conformity_assessment_body_number
    uk_market_conformity_assessment_body_type
    uk_market_conformity_assessment_body_registered_office_location
    uk_market_conformity_assessment_body_testing_locations
    uk_market_conformity_assessment_body_website
    uk_market_conformity_assessment_body_email
    uk_market_conformity_assessment_body_phone
    uk_market_conformity_assessment_body_legislative_area
    uk_market_conformity_assessment_body_notified_body_number
    uk_market_conformity_assessment_body_address
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    []
  end

  def self.title
    "UK Market Conformity Assessment Body"
  end

  def primary_publishing_organisation
    "2bde479a-97f2-42b5-986a-287a623c2a1c"
  end
end
