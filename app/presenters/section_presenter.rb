class SectionPresenter
  def initialize(section)
    @section = section
  end

  def to_json
    {
      base_path: @section.base_path,
      title: @section.title,
      description: @section.summary,
      format: "manual_section",
      need_ids: [],
      locale: "en",
      public_updated_at: @section.public_updated_at.to_datetime.rfc3339,
      publishing_app: "specialist-publisher",
      rendering_app: "manuals-frontend",
      details: {
      body: @section.body,
      manual: {
      base_path: @section.manual.base_path
    },
      organisations: []
    },
      routes: [{
      path: @section.base_path,
      type: "exact"
    }]
    }
  end
end
