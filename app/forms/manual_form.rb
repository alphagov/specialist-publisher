class ManualForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :title, :summary, :organisation_slug

  validates :title, presence: true

  def initialize(manual = nil)
    @manual = manual
    @new_documents = []

    if manual
      @id = manual.id
      @title = manual.title
      @summary = manual.summary
      @organisation_slug = manual.organisation_slug
    end
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Manual")
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
    manual.present?
  end

  def to_param
    id
  end

  def documents
    manual && manual.documents || []
  end

private
  attr_reader :manual
end
