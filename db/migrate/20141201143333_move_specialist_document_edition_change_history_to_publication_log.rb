class MoveSpecialistDocumentEditionChangeHistoryToPublicationLog < Mongoid::Migration
  def self.up
    editions_with_change_history.each do |edition|
      latest_change = edition.change_history.last

      PublicationLog.create!(
        slug: edition.slug,
        title: edition.title,
        change_note: latest_change.note,
        version_number: edition.version_number,
      )
    end
  end

  def self.down
    raise IrreversibleMigration
  end

private
  def self.editions_with_change_history
    SpecialistDocumentEdition.where(:change_history.ne => nil)
  end
end
