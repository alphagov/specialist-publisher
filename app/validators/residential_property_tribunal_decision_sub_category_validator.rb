class ResidentialPropertyTribunalDecisionSubCategoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if [record.tribunal_decision_category, value].any?(&:blank?)

    record.errors.add(attribute, error_message) unless related_sub_category?(record.tribunal_decision_category, value)
  end

private

  def related_sub_category?(category, sub_category)
    category_from_sub_category, _sub_category_from_sub_category = sub_category&.split("---", 2)
    category == category_from_sub_category
  end

  def error_message
    options[:message] || "must belong to the selected tribunal decision category"
  end
end
