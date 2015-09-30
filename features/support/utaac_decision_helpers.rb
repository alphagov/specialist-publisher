module UtaacDecisionHelpers
  def create_utaac_decision(fields, **kwargs)
    create_document(:utaac_decision, fields, **kwargs)
  end

  def go_to_show_page_for_utaac_decision(*args)
    go_to_show_page_for_document(:utaac_decision, *args)
  end

  def check_utaac_decision_exists_with(*args)
    check_document_exists_with(:utaac_decision, *args)
  end

  def go_to_utaac_decision_index
    visit_path_if_elsewhere(utaac_decisions_path)
  end

  def go_to_edit_page_for_utaac_decision(*args)
    go_to_edit_page_for_document(:utaac_decision, *args)
  end

  def edit_utaac_decision(title, *args)
    go_to_edit_page_for_utaac_decision(title)
    edit_document(title, *args)
  end

  def check_for_new_utaac_decision_title(*args)
    check_for_new_document_title(:utaac_decision, *args)
  end

  def withdraw_utaac_decision(*args)
    withdraw_document(:utaac_decision, *args)
  end

  def create_multiple_utaac_decisions(titles)
    titles.each do |title|
      create_document(:utaac_decision, utaac_decision_fields(title: title))
    end
  end

  def utaac_decisions_are_visible(titles)
    titles.each { |t| utaac_decision_is_visible(t) }
  end

  def utaac_decision_is_visible(title)
    expect(page).to have_content(title)
  end

  def utaac_decisions_are_not_visible(titles)
    titles.each do |title|
      expect(page).not_to have_content(title)
    end
  end

  def utaac_decision_fields(overrides = {})
    {
      title: "Lorem ipsum",
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Link to attachement:",
      "Category" => "Benefits for children",
      "Sub-category" => "Benefits for children - child benefit",
      "Judges" => "Angus, R",
      "Decision date" => "2015-02-02",
      "Hidden indexable content" => "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10)
    }.merge(overrides)
  end

  def utaac_decision_rummager_fields(overrides = {})
    fields = utaac_decision_fields(overrides)
    fields.delete(:body)
    fields.delete("Hidden indexable content")
    category = fields.delete("Category")
    sub_category = fields.delete("Sub-category")
    judges = fields.delete("Judges")

    fields[:tribunal_decision_category] = category.parameterize
    fields[:tribunal_decision_category_name] = category
    fields[:tribunal_decision_sub_category] = sub_category.parameterize
    fields[:tribunal_decision_sub_category_name] = sub_category
    fields[:tribunal_decision_judges] = [judges.parameterize]
    fields[:tribunal_decision_judges_name] = [judges]
    fields[:tribunal_decision_decision_date] = fields.delete("Decision date")
    fields
  end
end
RSpec.configuration.include UtaacDecisionHelpers, type: :feature
