module MaibReportHelpers
  def create_maib_report(*args)
    create_document(:maib_report, *args)
  end

  def go_to_show_page_for_maib_report(*args)
    go_to_show_page_for_document(:maib_report, *args)
  end

  def check_maib_report_exists_with(*args)
    check_document_exists_with(:maib_report, *args)
  end

  def go_to_maib_report_index
    visit_path_if_elsewhere(maib_reports_path)
  end

  def go_to_edit_page_for_maib_report(*args)
    go_to_edit_page_for_document(:maib_report, *args)
  end

  def edit_maib_report(title, *args)
    go_to_edit_page_for_maib_report(title)
    edit_document(title, *args)
  end

  def check_for_new_maib_report_title(*args)
    check_for_new_document_title(:maib_report, *args)
  end

  def withdraw_maib_report(*args)
    withdraw_document(:maib_report, *args)
  end
end
RSpec.configuration.include MaibReportHelpers, type: :feature
