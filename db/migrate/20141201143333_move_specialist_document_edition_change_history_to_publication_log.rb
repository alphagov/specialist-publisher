class MoveSpecialistDocumentEditionChangeHistoryToPublicationLog < Mongoid::Migration
  def self.up
    editions_with_change_history.each do |edition|
      latest_change = edition.change_history.last

      if latest_change
        PublicationLog.create!(
          slug: edition.slug,
          title: edition.title,
          change_note: latest_change.respond_to?(:note) ? latest_change.note : "First published.",
          version_number: edition.version_number,
        )
      end
    end
  end

  def self.down
    raise IrreversibleMigration
  end

private
  def self.editions_with_change_history
    SpecialistDocumentEdition.where(:change_history.nin => [nil, []]).to_a.uniq { |e| e.document_id }
  end
end
