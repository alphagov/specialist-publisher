module DsuHelpers
  def create_drug_safety_update(*args)
    Timecop.freeze("2001-01-01 01:00:00")
    create_document(:drug_safety_update, *args)
  end

  def go_to_show_page_for_drug_safety_update(*args)
    go_to_show_page_for_document(:drug_safety_update, *args)
  end

  def check_drug_safety_update_exists_with(*args)
    check_document_exists_with(:drug_safety_update, *args)
  end

  def go_to_drug_safety_update_index
    visit_path_if_elsewhere(drug_safety_updates_path)
  end

  def go_to_edit_page_for_drug_safety_update(*args)
    go_to_edit_page_for_document(:drug_safety_update, *args)
  end

  def edit_drug_safety_update(title, *args)
    go_to_edit_page_for_drug_safety_update(title)
    edit_document(title, *args)
  end

  def check_for_new_drug_safety_update_title(*args)
    check_for_new_document_title(:drug_safety_update, *args)
  end

  def withdraw_drug_safety_update(*args)
    withdraw_document(:drug_safety_update, *args)
  end
end
RSpec.configuration.include DsuHelpers, type: :feature
