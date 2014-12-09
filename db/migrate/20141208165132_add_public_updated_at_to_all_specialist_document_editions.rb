class AddPublicUpdatedAtToAllSpecialistDocumentEditions < Mongoid::Migration
  def self.up
    editions = SpecialistDocumentEdition.where(:document_type.in => %w(
      cma_case
      aaib_report
      maib_report
      raib_report
      drug_safety_update
      medical_safety_alert
      international_development_fund
    ))

    editions.each do |edition|
      # use set in order to not touch updated_at timestamps
      edition.set(:public_updated_at, edition.updated_at.utc)
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
