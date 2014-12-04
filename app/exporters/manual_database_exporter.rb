class ManualDatabaseExporter

  def initialize(export_recipent, manual)
    @export_recipent = export_recipent
    @manual = manual
  end

  def call
    export_recipent.create_or_update_by_slug!(exportable_attributes)
  end

private

  attr_reader :export_recipent, :manual

  def exportable_attributes
    manual.attributes
      .except(:id)
      .merge(section_data)
  end

  def section_data
    {
      section_groups: [
        {
          title: "Contents",
          sections: sections,
        }
      ]
    }
  end

  def sections
    manual.documents.map { |d|
      {
        title: d.title,
        summary: d.summary,
        slug: d.slug,
      }
    }
  end
end
