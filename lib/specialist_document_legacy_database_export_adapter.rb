class SpecialistDocumentLegacyDatabaseExportAdapter

  def initialize(export_recipent)
    @export_recipent = export_recipent
  end

  def create_or_update_by_slug!(attributes)
    export_recipent.create_or_update_by_slug!(legacy_attributes(attributes))
  end

private

  attr_reader :export_recipent

  def legacy_attributes(attributes)
    attributes.merge(
      attributes.fetch(:details)
    )
  end
end
