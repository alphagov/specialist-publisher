require "delegate"

class CoreDocumentValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :summary, presence: true
  validates :title, presence: true
  validates :body, presence: true
end
