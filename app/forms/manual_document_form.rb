require "forwardable"

class ManualDocumentForm
  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  # include ActiveModel::Validations

  def_delegators :document, :exposed_edition


  def errors
    if document
      document.errors
    else
      {}
    end
  end

  def valid?
    if document
      document.valid?
    else
      true
    end
  end

  attr_accessor(
    :title,
    :summary,
    :body,
    :opened_date,
    :closed_date,
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type,
  )

  def initialize(manual, document = nil)
    @manual = manual
    @document = document

    if document
      @id = document.id
      @title = document.title
      @summary = document.summary
      @body = document.body
      @opened_date = document.opened_date
      @closed_date = document.closed_date
      @case_type = document.case_type
      @case_state = document.case_state
      @market_sector = document.market_sector
      @outcome_type = document.outcome_type
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Document")
  end

  def id
    @id ||= SecureRandom.uuid
  end

  def update(attributes)
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    document.present?
  end

  def to_param
    id
  end

  def attachments
    []
  end

private
  attr_reader :manual, :document
end
