class EsiFundViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
    :fund_state,
    :fund_type,
    :location,
    :funding_source,
    :closing_date,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "EsiFund")
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:esi_fund_finder_schema)
  end

end
