require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class EmploymentAppealTribunalDecisionValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :tribunal_decision_categories, presence: true
  validates :tribunal_decision_decision_date, presence: true, date: true
  validates :tribunal_decision_landmark, presence: true
  validates :tribunal_decision_sub_categories, presence: true

end
