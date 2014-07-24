class AaibReportViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
    :date_of_occurrence,
    :aircraft_category,
    :report_type,
    :aircraft_type,
    :registration,
    :location,
  ]

  def self.model_name
    ActiveModel::Name.new(self, nil, "AaibReport")
  end

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:aaib_report_finder_schema)
  end
end
