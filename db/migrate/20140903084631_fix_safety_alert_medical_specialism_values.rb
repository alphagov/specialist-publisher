class FixSafetyAlertMedicalSpecialismValues < Mongoid::Migration
  class Edition
    include Mongoid::Document

    store_in :specialist_document_editions
  end

  def self.up
    remove__and__from_medical_specialism
    remove_comma_from_therapeutic_area
  end

  def self.down
    raise IrreversibleMigration
  end

  def self.remove_comma_from_therapeutic_area
    drug_safety_updates.each do |e|
      therapeutic_area = e.extra_fields.fetch("therapeutic_area").map { |v|
        v.sub(",", "")
      }

      e.extra_fields = e.extra_fields.merge(
        "therapeutic_area" => therapeutic_area,
      )

      e.save!
    end
  end

  def self.remove__and__from_medical_specialism
    medical_safety_alerts.each do |e|
      medical_specialism = e.extra_fields.fetch("medical_specialism").map { |v|
        v.sub("-and-", "-")
      }

      e.extra_fields = e.extra_fields.merge(
        "medical_specialism" => medical_specialism,
      )

      e.save!
    end
  end

  def self.medical_safety_alerts
    Edition.where(document_type: "medical_safety_alert")
  end

  def self.drug_safety_updates
    Edition.where(document_type: "drug_safety_update")
  end
end
