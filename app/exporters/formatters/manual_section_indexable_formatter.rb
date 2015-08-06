class ManualSectionIndexableFormatter
  def initialize(section, manual)
    @section = section
    @manual = manual
  end

  def type
    "manual_section"
  end

  def id
    link
  end

  def indexable_attributes
    {
      title: "#{manual.title}: #{section.title}",
      description: section.summary,
      link: link,
      indexable_content: section.body,
      organisations: [manual.organisation_slug],
      manual: manual.slug,
    }
  end

private
  attr_reader :section, :manual

  def extra_attributes
    {}
  end

  def link
    with_leading_slash(section.slug)
  end

  def with_leading_slash(slug)
    slug.start_with?("/") ? slug : "/#{slug}"
  end
end
