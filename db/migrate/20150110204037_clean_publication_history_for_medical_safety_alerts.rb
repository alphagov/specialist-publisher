class CleanPublicationHistoryForMedicalSafetyAlerts < Mongoid::Migration
  def self.up
    ids = %w(
      c5e16c47-c086-4ce8-820a-19d899c22dc1
      44ce845f-d25a-47e1-8c50-38ad549758ad
      2fa0d357-1f87-4259-b17b-266d4ca4e9e4
      60f24290-bc82-41de-b93d-db0daa5982a7
      691e960d-2557-4b3d-ab42-db82e6e45144
    )

    editions = SpecialistDocumentEdition.where(:document_id.in => ids)

    puts "Setting bulk_published flag for #{editions.count} SpecialistDocumentEdition records"
    editions.each do |e|
      e.extra_fields["bulk_published"] = true
      e.save!
    end

    slugs = editions.map(&:slug).uniq
    publication_logs = PublicationLog.where(:slug.in => slugs)

    puts "Deleting #{publication_logs.count} PublicationLog records"
    publication_logs.each(&:delete)
  end

  def self.down
    raise IrreversibleMigration
  end
end
