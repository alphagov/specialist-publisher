class TribunalDecisionSubCategoryRelatesToParentValidator < ActiveModel::EachValidator

  def validate_each(validator, attribute, sub_category)

    unless prefixed_by_parent_category? sub_category, validator
      message = "change to be a sub-category of '#{category_label(validator)}' or change category"
      validator.errors.add attribute, message
    end
  end

  private

  def category_prefix(validator)
    category = validator.tribunal_decision_category
    prefix = category
    if validator.respond_to?(:category_prefix_for)
      category_prefix = validator.category_prefix_for(category)
      prefix = category_prefix if category_prefix.present?
    end
    prefix
  end

  def prefixed_by_parent_category?(sub_category, validator)
    prefix = category_prefix(validator)
    sub_category[/^#{prefix}/]
  end

  def category_label(validator)
    labels = FinderSchema.humanized_facet_name(:tribunal_decision_category, validator, type(validator))
    labels.first
  end

  def type(validator)
    validator.class.name.underscore.sub("_validator", "")
  end

end
