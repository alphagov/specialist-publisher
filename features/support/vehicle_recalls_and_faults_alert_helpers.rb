module VehicleRecallsAndFaultsAlertHelpers
  def create_vehicle_recalls_and_faults_alert(*args)
    create_document(:vehicle_recalls_and_faults_alert, *args)
  end

  def check_vehicle_recalls_and_faults_alert_exists_with(*args)
    check_document_exists_with(:vehicle_recalls_and_faults_alert, *args)
  end

  def go_to_show_page_for_vehicle_recalls_and_faults_alert(*args)
    go_to_show_page_for_document(:vehicle_recalls_and_faults_alert, *args)
  end

  def go_to_vehicle_recalls_and_faults_alert_index
    visit_path_if_elsewhere(vehicle_recalls_and_faults_alerts_path)
  end

  def go_to_edit_page_for_vehicle_recalls_and_faults_alert(*args)
    go_to_edit_page_for_document(:vehicle_recalls_and_faults_alert, *args)
  end

  def edit_vehicle_recalls_and_faults_alert(title, *args)
    go_to_edit_page_for_vehicle_recalls_and_faults_alert(title)
    edit_document(title, *args)
  end
end
RSpec.configuration.include VehicleRecallsAndFaultsAlertHelpers, type: :feature
