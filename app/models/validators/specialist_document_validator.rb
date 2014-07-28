require "delegate"

class SpecialistDocumentValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true
  validates_with SafeHtml
end
