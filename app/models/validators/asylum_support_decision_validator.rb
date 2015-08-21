require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class AsylumSupportDecisionValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :tribunal_decision_decision_date, presence: true
  validates :tribunal_decision_judges, presence: true
  validates :tribunal_decision_category, presence: true
  validates :tribunal_decision_sub_category, presence: true
  validates :tribunal_decision_landmark, presence: true
  validates :tribunal_decision_reference_number, presence: true

end
