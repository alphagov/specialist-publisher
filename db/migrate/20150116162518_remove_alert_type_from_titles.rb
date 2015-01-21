class RemoveAlertTypeFromTitles < Mongoid::Migration
  def self.up
    SpecialistDocumentEdition.where(document_type: "medical_safety_alert").order("updated_at ASC").each do |medical_safety_alert|
      title = medical_safety_alert.title
      title = title.gsub(/^Medical device alert: /, "").gsub(/^Drug alert: /, "")
      title[0] = title[0].capitalize
      medical_safety_alert.set(:title, title)
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
