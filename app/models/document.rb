class Document
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :title, :summary, :body, :format_specific_fields, :state, :bulk_published, :minor_update, :change_note

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true

  def initialize(params = {}, format_specific_fields = [])
    @title = params.fetch(:title, nil)
    @summary = params.fetch(:summary, nil)
    @body = params.fetch(:body, nil)
    @format_specific_fields = format_specific_fields

    format_specific_fields.each do |field|
      public_send(:"#{field.to_s}=", params.fetch(field, nil))
    end
  end

  def base_path
    "#{public_path}/#{title.parameterize}"
  end

  def content_id
    @content_id ||= SecureRandom.uuid
  end

  def format
    "document"
  end

  def phase
    "live"
  end

  def published?
    false
  end

  def organisations
    []
  end

  def users
    content_item.users || []
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

  def public_updated_at
    @public_updated_at ||= Time.zone.now
  end

private

  def finder_schema
    @finder_schema ||= FinderSchema.new(format.pluralize)
  end

end
