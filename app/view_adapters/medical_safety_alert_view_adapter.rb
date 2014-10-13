class MedicalSafetyAlertViewAdapter < DocumentViewAdapter
  attributes = [
    :alert_type,
    :medical_specialism,
    :issued_date,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "MedicalSafetyAlert")
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:medical_safety_alert_finder_schema)
  end

end
