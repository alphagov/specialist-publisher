class ResearchForDevelopmentOutput < Document
  apply_validations
  validates :review_status, presence: true

  FORMAT_SPECIFIC_FIELDS = format_specific_fields + [:review_status]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    self.author_tags = params[:author_tags]
  end

  ##
  # Research for Development outputs are always bulk published, because our 'publication'
  # is just a proxy for a research output PDF. Its date is not important to a
  # user. Setting this +true+ means that specialist-frontend will never render
  # the publishing-api +published+ date.
  def bulk_published
    true
  end

  def author_tags
    (authors || []).join("::")
  end

  def author_tags=(tags)
    self.authors = (tags || "").split("::")
  end
end
