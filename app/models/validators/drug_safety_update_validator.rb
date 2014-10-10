require "delegate"
require "validators/safe_html_validator"

class DrugSafetyUpdateValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true
end
