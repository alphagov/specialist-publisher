require "delegate"
require "validators/date_validator"

class InternationalDevelopmentFundValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true
end
