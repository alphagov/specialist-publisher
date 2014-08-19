class DrugSafetyUpdateViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
    :therapeutic_area,
  ]

  def self.model_name
    ActiveModel::Name.new(self, nil, "DrugSafetyUpdate")
  end

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:drug_safety_update_finder_schema)
  end
end
