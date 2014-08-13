class ManualPublishingAPIExporter

  def initialize(export_recipent, publication_logs, manual)
    @export_recipent = export_recipent
    @publication_logs = publication_logs
    @manual = manual
  end

  def call
    export_recipent.put_content_item(base_path, exportable_attributes)
  end

private

  attr_reader :export_recipent, :publication_logs, :manual

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
      details: details_data
    }
  end

  def details_data
    {
      child_section_groups: [
        {
          title: "Contents",
          child_sections: sections,
        }
      ],
      change_notes: serialised_change_notes,
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

  def serialised_change_notes
    publication_logs.change_notes_for(manual.attributes[:slug]).map { |publication|
      {
        base_path: "/#{publication.slug}",
        title: publication.title,
        change_note: publication.change_note,
        published_at: publication.published_at.utc,
      }
    }
  end
end
