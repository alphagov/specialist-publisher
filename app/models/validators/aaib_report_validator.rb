require "delegate"
require "validators/date_validator"

class AaibReportValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true

  validates :date_of_occurrence, presence: true, date: true
end
