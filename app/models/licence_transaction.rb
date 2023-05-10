class LicenceTransaction < Document
  validates_with LinkOrIdentifierValidator
  validates :primary_publishing_organisation, presence: true
  validates :licence_transaction_licence_identifier, licence_identifier_unique: true

  FORMAT_SPECIFIC_FIELDS = %i[
    licence_transaction_continuation_link
    licence_transaction_industry
    licence_transaction_licence_identifier
    licence_transaction_location
    licence_transaction_will_continue_on
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS, :organisations, :primary_publishing_organisation)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    @primary_publishing_organisation = params[:primary_publishing_organisation]
    @organisations = params[:organisations]
  end

  def taxons
    []
  end

  def self.title
    "Licence"
  end

  def self.has_organisations?
    true
  end

  def links
    super.merge(
      organisations: organisations | [primary_publishing_organisation],
      primary_publishing_organisation: [primary_publishing_organisation],
    )
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
