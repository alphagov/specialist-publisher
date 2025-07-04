class ResearchForDevelopmentOutput < Document
  apply_validations

  FORMAT_SPECIFIC_FIELDS = format_specific_fields + [:review_status]

  attr_accessor(*FORMAT_SPECIFIC_FIELDS, :is_using_design_system_view)

  def initialize(params = {})
    super(params, FORMAT_SPECIFIC_FIELDS)
    self.is_using_design_system_view = params[:is_using_design_system_view] || false
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

  def split_string
    is_using_design_system_view ? "\r\n" : "::"
  end

  def author_tags
    (authors || []).join(split_string)
  end

  def author_tags=(tags)
    self.authors = (tags || "").split(split_string).reject(&:blank?)
  end
end
