require "delegate"

class ManualDocumentValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :summary, presence: true
  validates :title, presence: true
  validates :body, presence: true
end
