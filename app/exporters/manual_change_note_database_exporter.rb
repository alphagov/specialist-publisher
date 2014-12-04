class ManualChangeNoteDatabaseExporter

  def initialize(dependencies)
    @export_target = dependencies.fetch(:export_target)
    @publication_logs = dependencies.fetch(:publication_logs)
    @manual = dependencies.fetch(:manual)
  end

  def call
    export_target.create_or_update_by_slug!(
      slug: change_notes_slug,
      updates: serialized_change_notes,
      manual_slug: manual.slug,
    )
  end

  private

  attr_reader :export_target, :publication_logs, :manual

  def change_notes_slug
    [manual.slug, "updates"].join("/")
  end

  def serialized_change_notes
    publication_logs.change_notes_for(manual.slug).map { |publication|
      {
        slug: publication.slug,
        title: publication.title,
        change_note: publication.change_note,
        published_at: publication.published_at.utc,
      }
    }
  end
end
