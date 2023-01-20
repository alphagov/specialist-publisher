class LicenceTransaction < Document
  FORMAT_SPECIFIC_FIELDS = %i[
    licence_transaction_continuation_link
    licence_transaction_industry
    licence_transaction_licence_identifier
    licence_transaction_location
    licence_transaction_will_continue_on
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

  def route_type
    "prefix"
  end

  def self.slug
    "licences"
  end

  def rendering_app
    "frontend"
  end
end
