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

  def humanized_attributes
    super.tap do |human_output|
      human_output.merge!(published_at: human_published_at) if published_at.present?
    end
  end

private

  def human_published_at
    published_at.strftime("%-d %B %Y, %H:%m")
  end

  def finder_schema
    SpecialistPublisherWiring.get(:drug_safety_update_finder_schema)
  end
end
