class ManualPresenter
  def initialize(manual)
    @manual = manual
  end

  def to_json
    {
      base_path: manual.base_path,
      content_id: manual.content_id,
      title: manual.title,
      description: manual.summary,
      format: "manual",
      locale: "en",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
      public_updated_at: manual.public_updated_at.to_datetime.rfc3339,
      details: {
        body: manual.body,
        child_section_groups: [],
        change_notes: []
      },
      routes: [
        {
          path: manual.base_path,
          type: "exact"
        }
      ],
      redirects: [],
      update_type: manual.update_type
    }
  end

private

  attr_reader :manual
end
