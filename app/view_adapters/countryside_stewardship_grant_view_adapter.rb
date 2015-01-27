class CountrysideStewardshipGrantViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "CountrysideStewardshipGrant")
  end

  private

  def finder_schema
    SpecialistPublisherWiring.get(:countryside_stewardship_grant_finder_schema)
  end

end
