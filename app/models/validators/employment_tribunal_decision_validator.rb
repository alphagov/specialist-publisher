require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class EmploymentTribunalDecisionValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_country, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true

end
