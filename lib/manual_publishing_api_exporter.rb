class ManualPublishingAPIExporter

  def initialize(export_recipent, manual)
    @export_recipent = export_recipent
    @manual = manual
  end

  def call
    export_recipent.put_content_item(base_path, exportable_attributes)
  end

private

  attr_reader :export_recipent, :manual

  def base_path
    "/#{manual.attributes[:slug]}"
  end

  def exportable_attributes
    {
      base_path: base_path,
      format: "manual",
      title: manual.attributes[:title],
      description: manual.attributes[:summary],
      public_updated_at: manual.attributes[:updated_at],
      update_type: "major",
      publishing_app: "specialist-publisher",
      rendering_app: "manuals-frontend",
      routes: [
        {
          path: base_path,
          type: "exact",
        }
      ],
      details: section_data
    }
  end

  def section_data
    {
      child_section_groups: [
        {
          title: "Contents",
          child_sections: sections,
        }
      ]
    }
  end

  def sections
    manual.documents.map { |d|
      {
        title: d.title,
        description: d.summary,
        base_path: "/#{d.slug}",
      }
    }
  end
end
