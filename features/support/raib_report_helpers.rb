module RaibReportHelpers
  def create_raib_report(*args)
    create_document(:raib_report, *args)
  end

  def go_to_show_page_for_raib_report(*args)
    go_to_show_page_for_document(:raib_report, *args)
  end

  def check_raib_report_exists_with(*args)
    check_document_exists_with(:raib_report, *args)
  end

  def go_to_raib_report_index
    visit_path_if_elsewhere(raib_reports_path)
  end

  def go_to_edit_page_for_raib_report(*args)
    go_to_edit_page_for_document(:raib_report, *args)
  end

  def edit_raib_report(title, *args)
    go_to_edit_page_for_raib_report(title)
    edit_document(title, *args)
  end

  def check_for_new_raib_report_title(*args)
    check_for_new_document_title(:raib_report, *args)
  end

  def withdraw_raib_report(*args)
    withdraw_document(:raib_report, *args)
  end
end
RSpec.configuration.include RaibReportHelpers, type: :feature
