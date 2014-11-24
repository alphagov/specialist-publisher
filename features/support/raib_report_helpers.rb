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

  def create_multiple_raib_reports(titles)
    base_data = {
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
      date_of_occurrence: "2014-01-01"
    }

    titles.each do |title|
      create_document(:raib_report, base_data.merge(title: title))
    end
  end

  def raib_reports_are_visible(titles)
    titles.each { |t| raib_report_is_visible(t) }
  end

  def raib_report_is_visible(title)
    expect(page).to have_content(title)
  end

  def raib_reports_are_not_visible(titles)
    titles.each do |title|
      expect(page).not_to have_content(title)
    end
  end
end
