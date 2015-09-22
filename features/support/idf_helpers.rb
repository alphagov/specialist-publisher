module IdfHelpers
  def create_international_development_fund(*args)
    create_document(:international_development_fund, *args)
  end

  def go_to_show_page_for_international_development_fund(*args)
    go_to_show_page_for_document(:international_development_fund, *args)
  end

  def check_international_development_fund_exists_with(*args)
    check_document_exists_with(:international_development_fund, *args)
  end

  def go_to_international_development_fund_index
    visit_path_if_elsewhere(international_development_funds_path)
  end

  def go_to_edit_page_for_international_development_fund(*args)
    go_to_edit_page_for_document(:international_development_fund, *args)
  end

  def edit_international_development_fund(title, *args)
    go_to_edit_page_for_international_development_fund(title)
    edit_document(title, *args)
  end

  def check_for_new_international_development_fund_title(*args)
    check_for_new_document_title(:international_development_fund, *args)
  end

  def withdraw_international_development_fund(*args)
    withdraw_document(:international_development_fund, *args)
  end
end
RSpec.configuration.include IdfHelpers, type: :feature
