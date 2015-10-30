require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"
require "validators/tribunal_decision_sub_category_relates_to_parent_validator"

class AsylumSupportDecisionValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :tribunal_decision_category, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true
  validates :tribunal_decision_judges, presence: true
  validates :tribunal_decision_landmark, presence: true
  validates :tribunal_decision_reference_number, presence: true
  validates :tribunal_decision_sub_category, tribunal_decision_sub_category_relates_to_parent: true

  def category_prefix_for(category)
    case category
    when "section-95-support-for-asylum-seekers"
      "section-95"
    when "section-4-2-support-for-failed-asylum-seekers"
      "section-4-2"
    when "section-4-1-support-for-persons-who-are-neither-an-asylum-seeker-nor-a-failed-asylum-seeker"
      "section-4-1"
    end
  end
end
