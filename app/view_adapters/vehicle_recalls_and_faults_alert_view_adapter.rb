class VehicleRecallsAndFaultsAlertViewAdapter < DocumentViewAdapter
  attributes = [
    :title,
    :summary,
    :body,
    :alert_issue_date,
    :fault_type,
    :faulty_item_type,
    :manufacturer,
    :faulty_item_model,
    :serial_number,
    :build_start_date,
    :build_end_date,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "VehicleRecallsAndFaultsAlert")
  end

private

  def finder_schema
    SpecialistPublisherWiring.get(:vehicle_recalls_and_faults_alert_finder_schema)
  end
end
