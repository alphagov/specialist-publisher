require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"
require "validators/tribunal_decision_sub_category_relates_to_parent_validator"

class UtaacDecisionValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :tribunal_decision_category, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true
  validates :tribunal_decision_judges, presence: true
  validates :tribunal_decision_sub_category, tribunal_decision_sub_category_relates_to_parent: true

end
