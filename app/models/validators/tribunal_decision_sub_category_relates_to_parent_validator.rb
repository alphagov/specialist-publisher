class TribunalDecisionSubCategoryRelatesToParentValidator < ActiveModel::EachValidator

  def validate_each(validator, attribute, sub_category)
    if sub_category.present?
      validate_sub_category(validator, attribute, sub_category)
    else
      validate_sub_category_present_if_parent_has_sub_categories(validator, attribute)
    end
  end

  private

  def validate_sub_category_present_if_parent_has_sub_categories(validator, attribute)
    if validator.tribunal_decision_category.present? && category_has_sub_categories?(validator)
      validator.errors.add attribute, "must not be blank"
    end
  end

  def category_has_sub_categories?(validator)
    prefix = category_prefix(validator)
    sub_category_allowed_values(validator).any? do
      |sub_category| sub_category[/^#{prefix}/]
    end
  end

  def sub_category_allowed_values(validator)
    sub_category_options = FinderSchema.options_for(:tribunal_decision_sub_category, type(validator))
    sub_category_options.map(&:last)
  end

  def validate_sub_category(validator, attribute, sub_category)
    if sub_category.size > 1
      validator.errors.add attribute, "change to a single sub-category"
    elsif !prefixed_by_parent_category?(sub_category.first, validator)
      message = if category_has_sub_categories?(validator)
                  "change to be a sub-category of '#{category_label(validator)}' or change category"
                else
                  "remove sub-category as '#{category_label(validator)}' category has no sub-categories"
                end
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
