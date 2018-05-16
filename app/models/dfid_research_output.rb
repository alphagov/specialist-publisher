class DfidResearchOutput < Document
  validates :first_published_at, presence: true, date: true
  validates :dfid_theme, presence: true
  validates :dfid_document_type, presence: true

  FORMAT_SPECIFIC_FIELDS = %i(
    dfid_document_type
    country
    first_published_at
    dfid_authors
    dfid_theme
    dfid_review_status
  ).freeze

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    self.dfid_author_tags = params[:dfid_author_tags]
  end

  ##
  # DFID research outputs are always bulk published, because our 'publication'
  # is just a proxy for a research output PDF. Its date is not important to a
  # user. Setting this +true+ means that specialist-frontend will never render
  # the publishing-api +published+ date.
  def bulk_published
    true
  end

  def self.title
    'DFID Research Output'
  end

  def first_draft?
    draft? && state_history_one_or_shorter?
  end

  def state_history_one_or_shorter?
    state_history.nil? ? true : state_history.size < 2
  end

  def dfid_author_tags
    (dfid_authors || []).join("::")
  end

  def dfid_author_tags=(tags)
    self.dfid_authors = (tags || "").split("::")
  end

  def primary_publishing_organisation
    'db994552-7644-404d-a770-a2fe659c661f'
  end
end
