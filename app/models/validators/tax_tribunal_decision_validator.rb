require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class TaxTribunalDecisionValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :tribunal_decision_category, presence: true
  validates :tribunal_decision_decision_date, allow_blank: true, date: true

end
