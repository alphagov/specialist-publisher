require "forwardable"

class CmaCaseForm < SimpleDelegator
  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true
  validates :opened_date, presence: true
  validates :market_sector, presence: true
  validates :case_type, presence: true
  validates :case_state, presence: true

  attributes = [
    :title,
    :summary,
    :body,
    :opened_date,
    :closed_date,
    :market_sector,
    :case_type,
    :case_state,
    :outcome_type,
  ]

  attributes.each do |attribute_name|
    define_method(attribute_name) do
      delegate_if_document_exists(attribute_name)
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "SpecialistDocument")
  end

  def initialize(document)
    @document = document
    super(document)
  end

  def attachments
    document && document.attachments || []
  end

  def persisted?
    document && document.updated_at
  end

  def to_param
    document.id
  end

  private

  attr_reader :document

  def delegate_if_document_exists(attribute_name)
    document && document.public_send(attribute_name)
  end
end
