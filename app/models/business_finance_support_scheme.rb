class BusinessFinanceSupportScheme < Document
  validates :business_sizes, presence: true
  validates :business_stages, presence: true
  validates :continuation_link, presence: true
  validates :industries, presence: true
  validates :regions, presence: true
  validates :types_of_support, presence: true

  FORMAT_SPECIFIC_FIELDS = %i[
    business_sizes
    business_stages
    continuation_link
    industries
    regions
    types_of_support
    will_continue_on
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def self.exportable?
    true
  end

  def self.title
    "Business Finance Support Scheme"
  end
end
