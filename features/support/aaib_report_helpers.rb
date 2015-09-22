module AaibReportHelpers
  def create_aaib_report(fields, **kwargs)
    create_document(:aaib_report, fields, **kwargs)
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

  def edit_aaib_report(title, *args)
    go_to_edit_page_for_aaib_report(title)
    edit_document(title, *args)
  end

  def check_for_new_aaib_report_title(*args)
    check_for_new_document_title(:aaib_report, *args)
  end

  def withdraw_aaib_report(*args)
    withdraw_document(:aaib_report, *args)
  end

  def create_multiple_aaib_reports(titles)
    base_data = {
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
      date_of_occurrence: "2014-01-01"
    }

    titles.each do |title|
      create_document(:aaib_report, base_data.merge(title: title))
    end
  end

  def aaib_reports_are_visible(titles)
    titles.each { |t| aaib_report_is_visible(t) }
  end

  def aaib_report_is_visible(title)
    expect(page).to have_content(title)
  end

  def aaib_reports_are_not_visible(titles)
    titles.each do |title|
      expect(page).not_to have_content(title)
    end
  end
end
RSpec.configuration.include AaibReportHelpers, type: :feature
