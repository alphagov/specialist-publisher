module AsylumSupportDecisionHelpers
  def create_asylum_support_decision(fields, **kwargs)
    create_document(:asylum_support_decision, fields, **kwargs)
  end

  def go_to_show_page_for_asylum_support_decision(*args)
    go_to_show_page_for_document(:asylum_support_decision, *args)
  end

  def check_asylum_support_decision_exists_with(*args)
    check_document_exists_with(:asylum_support_decision, *args)
  end

  def go_to_asylum_support_decision_index
    visit_path_if_elsewhere(asylum_support_decisions_path)
  end

  def go_to_edit_page_for_asylum_support_decision(*args)
    go_to_edit_page_for_document(:asylum_support_decision, *args)
  end

  def edit_asylum_support_decision(title, *args)
    go_to_edit_page_for_asylum_support_decision(title)
    edit_document(title, *args)
  end

  def check_for_new_asylum_support_decision_title(*args)
    check_for_new_document_title(:asylum_support_decision, *args)
  end

  def withdraw_asylum_support_decision(*args)
    withdraw_document(:asylum_support_decision, *args)
  end

  def create_multiple_asylum_support_decisions(titles)
    titles.each do |title|
      create_document(:asylum_support_decision, asylum_support_decision_fields(title: title))
    end
  end

  def asylum_support_decisions_are_visible(titles)
    titles.each { |t| asylum_support_decision_is_visible(t) }
  end

  def asylum_support_decision_is_visible(title)
    expect(page).to have_content(title)
  end

  def asylum_support_decisions_are_not_visible(titles)
    titles.each do |title|
      expect(page).not_to have_content(title)
    end
  end

  def asylum_support_decision_fields(overrides = {})
    {
      title: "Lorem ipsum",
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Link to attachement:",
      "Category" => "Section 95 (support for asylum seekers)",
      "Sub-category" => "Section 95 - jurisdiction",
      "Judges" => "Bashir, S",
      "Decision date" => "2015-02-02",
      "Landmark" => "Landmark",
      "Reference number" => "1234",
      "Hidden indexable content" => "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10)
    }.merge(overrides)
  end

  def asylum_support_decision_rummager_fields(overrides = {})
    fields = asylum_support_decision_fields(overrides)
    fields.delete(:body)
    fields.delete("Hidden indexable content")
    category = fields.delete("Category")
    sub_category = fields.delete("Sub-category")
    judges = fields.delete("Judges")
    landmark = fields.delete("Landmark")

    fields[:tribunal_decision_category] = category.parameterize
    fields[:tribunal_decision_category_name] = category
    fields[:tribunal_decision_sub_category] = sub_category.parameterize
    fields[:tribunal_decision_sub_category_name] = sub_category
    fields[:tribunal_decision_judges] = [judges.parameterize]
    fields[:tribunal_decision_judges_name] = [judges]
    fields[:tribunal_decision_decision_date] = fields.delete("Decision date")
    fields[:tribunal_decision_landmark] = landmark.parameterize
    fields[:tribunal_decision_landmark_name] = landmark
    fields[:tribunal_decision_reference_number] = fields.delete("Reference number")
    fields
  end
end
RSpec.configuration.include AsylumSupportDecisionHelpers, type: :feature
