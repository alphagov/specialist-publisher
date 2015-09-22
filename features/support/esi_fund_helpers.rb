module EsiFundHelpers
  def create_esi_fund(*args)
    create_document(:esi_fund, *args)
  end

  def go_to_show_page_for_esi_fund(*args)
    go_to_show_page_for_document(:esi_fund, *args)
  end

  def check_esi_fund_exists_with(*args)
    check_document_exists_with(:esi_fund, *args)
  end

  def go_to_esi_fund_index
    visit_path_if_elsewhere(esi_funds_path)
  end

  def go_to_edit_page_for_esi_fund(*args)
    go_to_edit_page_for_document(:esi_fund, *args)
  end

  def edit_esi_fund(title, *args)
    go_to_edit_page_for_esi_fund(title)
    edit_document(title, *args)
  end

  def check_for_new_esi_fund_title(*args)
    check_for_new_document_title(:esi_fund, *args)
  end

  def withdraw_esi_fund(*args)
    withdraw_document(:esi_fund, *args)
  end
end
RSpec.configuration.include EsiFundHelpers, type: :feature
