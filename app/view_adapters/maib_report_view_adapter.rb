class MaibReportViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
    :date_of_occurrence,
    :report_type,
    :vessel_type,
  ]

  def self.model_name
    ActiveModel::Name.new(self, nil, "MaibReport")
  end

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:maib_report_finder_schema)
  end
end
