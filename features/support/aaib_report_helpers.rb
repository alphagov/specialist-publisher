module AaibReportHelpers
  def create_aaib_report(*args)
    create_document(:aaib_report, *args)
  end

  def go_to_show_page_for_aaib_report(*args)
    go_to_show_page_for_document(:aaib_report, *args)
  end

  def check_aaib_report_exists_with(*args)
    check_document_exists_with(:aaib_report, *args)
  end

  def go_to_aaib_report_index
    visit_path_if_elsewhere(aaib_reports_path)
  end

  def go_to_edit_page_for_aaib_report(*args)
    go_to_edit_page_for_document(:aaib_report, *args)
  end

  def edit_aaib_report(*args)
    edit_document(:aaib_report, *args)
  end

  def check_for_new_aaib_report_title(*args)
    check_for_new_document_title(:aaib_report, *args)
  end

end
