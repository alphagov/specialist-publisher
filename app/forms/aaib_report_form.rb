class AaibReportForm < DocumentForm
  attributes = [
    :title,
    :summary,
    :body,
    :date_of_occurrence,
    :aircraft_category,
    :report_type,
  ]

  def self.model_name
    ActiveModel::Name.new(self, nil, "AaibReport")
  end

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end
end
