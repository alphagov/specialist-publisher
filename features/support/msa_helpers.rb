module MsaHelpers
  def create_medical_safety_alert(*args)
    create_document(:medical_safety_alert, *args)
  end

  def go_to_show_page_for_medical_safety_alert(*args)
    go_to_show_page_for_document(:medical_safety_alert, *args)
  end

  def check_medical_safety_alert_exists_with(*args)
    check_document_exists_with(:medical_safety_alert, *args)
  end

  def go_to_medical_safety_alert_index
    visit_path_if_elsewhere(medical_safety_alerts_path)
  end

  def go_to_edit_page_for_medical_safety_alert(*args)
    go_to_edit_page_for_document(:medical_safety_alert, *args)
  end

  def edit_medical_safety_alert(title, *args)
    go_to_edit_page_for_medical_safety_alert(title)
    edit_document(title, *args)
  end

  def check_for_new_medical_safety_alert_title(*args)
    check_for_new_document_title(:medical_safety_alert, *args)
  end

  def withdraw_medical_safety_alert(*args)
    withdraw_document(:medical_safety_alert, *args)
  end
end
RSpec.configuration.include MsaHelpers, type: :feature
