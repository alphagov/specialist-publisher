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

  def create_multiple_maib_reports(titles)
    base_data = {
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
      date_of_occurrence: "2014-01-01"
    }

    titles.each do |title|
      create_document(:maib_report, base_data.merge(title: title))
    end
  end

  def maib_reports_are_visible(titles)
    titles.each { |t| maib_report_is_visible(t) }
  end

  def maib_report_is_visible(title)
    expect(page).to have_content(title)
  end

  def maib_reports_are_not_visible(titles)
    titles.each do |title|
      expect(page).not_to have_content(title)
    end
  end
end
