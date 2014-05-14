require "forwardable"

class ManualDocumentForm
  extend Forwardable
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def_delegators :document, :exposed_edition, :add_attachment, :attachments

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
    :case_type,
    :case_state,
    :market_sector,
    :outcome_type,
    :closed_date,
  )

  def initialize(manual, document = nil)
    @manual = manual
    @document = document

    if document
      @id = document.id
      @title = document.title
      @summary = document.summary
      @body = document.body

      # TODO: Remove this hack for irrelevant required CMA fields
      @opened_date = Date.parse('1/04/2014')
      @market_sector = 'manual'
      @case_type = 'manual'
      @case_state = 'manual'

      document.update(
        opened_date: @opened_date,
        market_sector: @market_sector,
        case_type: @case_type,
        case_state: @case_state,
      )
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
    document && document.attachments || []
  end

private
  attr_reader :manual, :document
end
