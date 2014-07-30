require "delegate"

class SpecialistDocumentValidator < SimpleDelegator
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true

  def valid?
    super
    validate_with_safe_html
    errors.empty?
  end

private

  def validate_with_safe_html
    SafeHtml.new({}).check_string(self, "body", body)
  end
end
