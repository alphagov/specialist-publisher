class AsylumSupportDecisionSubCategoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, error_message) unless related_sub_category?(record.tribunal_decision_categories, value)
  end

private

  def related_sub_category?(category, sub_category)
    split_category = category.split("-")
    split_sub_category = sub_category.split("-")
    if split_category[1] == "95"
      split_category[1] == split_sub_category[1]
    else
      split_category[2] == split_sub_category[2]
    end
  rescue ArgumentError
    false
  end

  def error_message
    options[:message] || "cannot be a different section to the one chosen in the category"
  end
end
