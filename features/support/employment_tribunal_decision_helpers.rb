module EmploymentTribunalDecisionHelpers
  def create_employment_tribunal_decision(fields, **kwargs)
    create_document(:employment_tribunal_decision, fields, **kwargs)
  end

  def go_to_show_page_for_employment_tribunal_decision(*args)
    go_to_show_page_for_document(:employment_tribunal_decision, *args)
  end

  def check_employment_tribunal_decision_exists_with(*args)
    check_document_exists_with(:employment_tribunal_decision, *args)
  end

  def go_to_employment_tribunal_decision_index
    visit_path_if_elsewhere(employment_tribunal_decisions_path)
  end

  def go_to_edit_page_for_employment_tribunal_decision(*args)
    go_to_edit_page_for_document(:employment_tribunal_decision, *args)
  end

  def edit_employment_tribunal_decision(title, *args)
    go_to_edit_page_for_employment_tribunal_decision(title)
    edit_document(title, *args)
  end

  def check_for_new_employment_tribunal_decision_title(*args)
    check_for_new_document_title(:employment_tribunal_decision, *args)
  end

  def withdraw_employment_tribunal_decision(*args)
    withdraw_document(:employment_tribunal_decision, *args)
  end

  def create_multiple_employment_tribunal_decisions(titles)
    titles.each do |title|
      create_document(:employment_tribunal_decision, employment_tribunal_decision_fields(title: title))
    end
  end

  def employment_tribunal_decisions_are_visible(titles)
    titles.each { |t| employment_tribunal_decision_is_visible(t) }
  end

  def employment_tribunal_decision_is_visible(title)
    expect(page).to have_content(title)
  end

  def employment_tribunal_decisions_are_not_visible(titles)
    titles.each do |title|
      expect(page).not_to have_content(title)
    end
  end

  def employment_tribunal_decision_fields(overrides = {})
    {
      title: "Lorem ipsum",
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Link to attachement:",
      "Jurisdiction code" => "Age Discrimination",
      "Decision date" => "2015-02-02",
      "Hidden indexable content" => "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10)
    }.merge(overrides)
  end

  def employment_tribunal_decision_rummager_fields(overrides = {})
    fields = employment_tribunal_decision_fields(overrides)
    fields.delete(:body)
    fields.delete("Hidden indexable content")
    category = fields.delete("Jurisdiction code")

    fields[:tribunal_decision_categories] = [category.parameterize]
    fields[:tribunal_decision_categories_name] = [category]
    fields[:tribunal_decision_decision_date] = fields.delete("Decision date")
    fields
  end
end
RSpec.configuration.include EmploymentTribunalDecisionHelpers, type: :feature
