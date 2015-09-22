module CsgHelpers
  def create_countryside_stewardship_grant(*args)
    create_document(:countryside_stewardship_grant, *args)
  end

  def go_to_show_page_for_countryside_stewardship_grant(*args)
    go_to_show_page_for_document(:countryside_stewardship_grant, *args)
  end

  def check_countryside_stewardship_grant_exists_with(*args)
    check_document_exists_with(:countryside_stewardship_grant, *args)
  end

  def go_to_countryside_stewardship_grant_index
    visit_path_if_elsewhere(countryside_stewardship_grants_path)
  end

  def go_to_edit_page_for_countryside_stewardship_grant(*args)
    go_to_edit_page_for_document(:countryside_stewardship_grant, *args)
  end

  def edit_countryside_stewardship_grant(title, *args)
    go_to_edit_page_for_countryside_stewardship_grant(title)
    edit_document(title, *args)
  end

  def check_for_new_countryside_stewardship_grant_title(*args)
    check_for_new_document_title(:countryside_stewardship_grant, *args)
  end

  def withdraw_countryside_stewardship_grant(*args)
    withdraw_document(:countryside_stewardship_grant, *args)
  end
end
RSpec.configuration.include CsgHelpers, type: :feature
