class CmaCaseViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
    :opened_date,
    :closed_date,
    :market_sector,
    :case_type,
    :case_state,
    :outcome_type,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "CmaCase")
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:cma_case_finder_schema)
  end

end
