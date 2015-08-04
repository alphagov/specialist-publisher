class ManualPublishingAPIExporter

  def initialize(export_recipent, organisation, manual_renderer, publication_logs, manual)
    @export_recipent = export_recipent
    @organisation = organisation
    @manual_renderer = manual_renderer
    @publication_logs = publication_logs
    @manual = manual
  end

  def call
    export_recipent.call(base_path, exportable_attributes)
  end

private

  attr_reader(
    :export_recipent,
    :organisation,
    :manual_renderer,
    :publication_logs,
    :manual
  )

  def base_path
    "/#{manual.attributes[:slug]}"
  end

  def updates_path
    [base_path, "updates"].join("/")
  end

  def exportable_attributes
    {
      content_id: manual.id,
      format: "manual",
      title: rendered_manual_attributes.fetch(:title),
      description: rendered_manual_attributes.fetch(:summary),
      public_updated_at: rendered_manual_attributes.fetch(:updated_at).iso8601,
      update_type: update_type,
      publishing_app: "specialist-publisher",
      rendering_app: "manuals-frontend",
      routes: [
        {
          path: base_path,
          type: "exact",
        },
        {
          path: updates_path,
          type: "exact",
        }
      ],
      details: details_data,
      locale: "en",
    }
  end

  def update_type
    manual.documents.all?(&:minor_update?) ? "minor" : "major"
  end

  def rendered_manual_attributes
    @rendered_manual_attributes ||= manual_renderer.call(manual).attributes
  end

  def details_data
    {
      body: rendered_manual_attributes.fetch(:body),
      child_section_groups: [
        {
          title: "Contents",
          child_sections: sections,
        }
      ],
      change_notes: serialised_change_notes,
      organisations: [
        organisation_info
      ]
    }
  end

  def sections
    manual.documents.map { |d|
      {
        title: d.attributes.fetch(:title),
        description: d.attributes.fetch(:summary),
        base_path: "/#{d.attributes.fetch(:slug)}",
      }
    }
  end

  def serialised_change_notes
    publication_logs.change_notes_for(manual.attributes.fetch(:slug)).map { |publication|
      {
        base_path: "/#{publication.slug}",
        title: publication.title,
        change_note: publication.change_note,
        published_at: publication.published_at.iso8601,
      }
    }
  end

  def organisation_info
    {
      title: organisation.title,
      abbreviation: organisation.details.abbreviation,
      web_url: organisation.web_url,
    }
  end
end
