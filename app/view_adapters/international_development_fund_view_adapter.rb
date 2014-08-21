class InternationalDevelopmentFundViewAdapter < DocumentViewAdapter
  attributes = [
    :fund_state,
    :location,
    :development_sector,
    :eligible_entities,
    :value_of_funding,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "InternationalDevelopmentFund")
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:international_development_fund_finder_schema)
  end

end
