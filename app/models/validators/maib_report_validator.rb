require "delegate"
require "validators/date_validator"
require "validators/safe_html_validator"

class MaibReportValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  validates :date_of_occurrence, presence: true, date: true
end
