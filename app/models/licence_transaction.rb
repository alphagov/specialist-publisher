class LicenceTransaction < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    country
    sector
    activity
    will_continue_on
    continuation_link
    licence_identifier
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    []
  end

  def self.title
    "Licence"
  end

  def primary_publishing_organisation
    # Set to GDS for testing
    "af07d5a5-df63-4ddc-9383-6a666845ebe9"
  end

  def self.slug
    "licences"
  end

  def rendering_app
    "frontend"
  end
end
