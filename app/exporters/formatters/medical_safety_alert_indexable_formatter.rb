require "formatters/abstract_specialist_document_indexable_formatter"

class MedicalSafetyAlertIndexableFormatter < AbstractSpecialistDocumentIndexableFormatter
  def type
    "medical_safety_alert"
  end

private
  def extra_attributes
    {
      alert_type: entity.alert_type,
      medical_specialism: entity.medical_specialism,
      issued_date: entity.issued_date,
    }
  end

  def organisation_slugs
    ["medicines-and-healthcare-products-regulatory-agency"]
  end
end
