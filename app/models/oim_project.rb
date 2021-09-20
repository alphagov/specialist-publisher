class OimProject < Document
  validates :oim_project_opened_date, allow_blank: true, date: true, open_before_closed: true
  validates :oim_project_closed_date, allow_blank: true, date: true
  validates :oim_project_type, presence: true
  validates :oim_project_state, presence: true
  FORMAT_SPECIFIC_FIELDS = %i[
    oim_project_opened_date
    oim_project_closed_date
    oim_project_type
    oim_project_state
  ].freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
  end

  def taxons
    []
  end

  def self.title
    "OIM Project"
  end

  def primary_publishing_organisation
    "b1123ceb-77e4-40fc-9526-83ad0ba7cf01"
  end
end
