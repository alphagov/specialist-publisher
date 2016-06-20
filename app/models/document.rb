class Document
  include ActiveModel::Model
  include ActiveModel::Validations
  include PublishingHelper

  attr_accessor :content_id, :base_path, :title, :summary, :body, :format_specific_fields, :public_updated_at, :state, :bulk_published, :publication_state, :change_note, :document_type, :attachments, :first_published_at

  attr_writer :change_history, :update_type

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true
  validates :update_type, presence: true, if: :live?
  validates :change_note, presence: true, if: :change_note_required?

  COMMON_FIELDS = [
    :title,
    :summary,
    :body,
    :publication_state,
    :public_updated_at,
    :first_published_at,
  ]

  FIRST_PUBLISHED_NOTE = 'First published.'.freeze

  def self.policy_class
    DocumentPolicy
  end

  def initialize(params = {}, format_specific_fields = [])
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @format_specific_fields = format_specific_fields

    (COMMON_FIELDS + format_specific_fields).each do |field|
      public_send(:"#{field.to_s}=", params.fetch(field, nil))
    end
  end

  def bulk_published
    @bulk_published || false
  end

  def base_path
    @base_path ||= "#{finder_schema.base_path}/#{title.parameterize}"
  end

  def document_type
    self.class.document_type
  end

  def self.document_type
    to_s.underscore
  end

  def search_document_type
    finder_schema.document_type_filter
  end

  def phase
    "live"
  end

  %w{draft live redrafted superseded unpublished}.each do |state|
    define_method("#{state}?") do
      publication_state == state
    end
  end

  def published?
    live? || redrafted?
  end

  def not_published?
    !published?
  end

  # TODO: This is not particularly robust. We'd prefer to check the entire
  # state history of the document to see if it had really ever been published
  # but that's not available via the publishing api yet.  Checking for our
  # "First published" note in change history is a stopgap until it is.
  def has_ever_been_published?
    change_history.detect { |notes| notes['note'] == Document::FIRST_PUBLISHED_NOTE }
  end

  def change_note_required?
    update_type == 'major' && published?
  end

  def change_history
    @change_history ||= []

    if change_note && update_type == 'major'
      @change_history + [{ 'public_timestamp' => Time.current.iso8601, 'note' => change_note }]
    else
      @change_history
    end
  end

  def update_type
    @update_type || "major"
  end

  def users
    content_item.users || []
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

  def organisations
    finder_schema.organisations
  end

  def self.organisations
    new.organisations
  end

  def format_specific_metadata
    format_specific_fields.each_with_object({}) do |f, fields|
      fields[f] = send(f)
    end
  end

  def humanized_attributes
    format_specific_metadata.inject({}) do |attributes, (key, value)|
      humanized_name = finder_schema.humanized_facet_name(key) { key }
      humanized_value = finder_schema.humanized_facet_value(key, value) { value }

      attributes.merge(humanized_name => humanized_value)
    end
  end

  def self.extract_body_from_payload(payload)
    body_attribute = payload.fetch('details').fetch('body')

    case body_attribute
    when Array
      govspeak_body = body_attribute.detect do |body_hash|
        body_hash['content_type'] == 'text/govspeak'
      end
      govspeak_body['content']
    when String
      body_attribute
    end
  end

  def self.from_publishing_api(payload)
    document = self.new(
      content_id: payload['content_id'],
      title: payload['title'],
      summary: payload['description'],
      body: extract_body_from_payload(payload),
      publication_state: payload['publication_state'],
      public_updated_at: payload['public_updated_at'],
      first_published_at: payload['first_published_at'],
    )

    document.base_path = payload['base_path']
    document.update_type = payload['update_type']

    document.bulk_published = payload['details']['metadata']['bulk_published']

    # If the document is redrafted remove the last/most
    # recent change note from the change_history array
    # and set it as the document's change note
    document.change_note = payload['details']['change_history'].pop["note"] if document.redrafted? && payload['details']['change_history'].length > 1
    # Persist the rest of the change_history on the document
    document.change_history = payload['details']['change_history'].map(&:to_h)

    document.attachments = Attachment.all_from_publishing_api(payload)

    document.format_specific_fields.each do |field|
      document.public_send(:"#{field.to_s}=", payload['details']['metadata'][field.to_s])
    end

    document
  end

  def self.all(page, per_page, q: nil)
    params = {
      document_type: self.document_type,
      fields: [
        :base_path,
        :content_id,
        :updated_at,
        :title,
        :publication_state,
      ],
      page: page,
      per_page: per_page,
      order: "-updated_at",
    }
    params[:q] = q if q.present?
    Services.publishing_api.get_content_items(params)
  end

  def self.find(content_id)
    response = Services.publishing_api.get_content(content_id)

    raise RecordNotFound, "Document: #{content_id}" unless response

    attributes = response.to_hash
    document_type = attributes.fetch("document_type")
    document_class = document_type.camelize.constantize

    if [document_class, Document].include?(self)
      document_class.from_publishing_api(response.to_hash)
    else
      message = "#{self}.find('#{content_id}') returned the wrong type: '#{document_class}'"
      raise TypeMismatchError, message
    end
  end

  class RecordNotFound < StandardError; end
  class TypeMismatchError < StandardError; end

  def save
    return false unless self.valid?

    presented_document = DocumentPresenter.new(self)
    presented_links = DocumentLinksPresenter.new(self)

    handle_remote_error do
      Services.publishing_api.put_content(self.content_id, presented_document.to_json)
      Services.publishing_api.patch_links(self.content_id, presented_links.to_json)
    end
  end

  def publish!
    handle_remote_error do
      update_type = self.update_type || 'major'

      unless has_ever_been_published?
        self.change_note = Document::FIRST_PUBLISHED_NOTE
        self.save
      end

      Services.publishing_api.publish(content_id, update_type)

      published_document = self.class.find(self.content_id)
      indexable_document = SearchPresenter.new(published_document)

      RummagerWorker.perform_async(
        search_document_type,
        base_path,
        indexable_document.to_json,
      )

      if send_email_on_publish?
        EmailAlertApiWorker.perform_async(EmailAlertPresenter.new(self).to_json)
      end
    end
  end

  def unpublish
    handle_remote_error do
      Services.publishing_api.unpublish(content_id, type: 'gone')
    end
  end

  def attachments=(attachments)
    @attachments = AttachmentCollection.new(attachments)
  end

  def attachments
    @attachments ||= AttachmentCollection.new
  end

  def upload_attachment(attachment)
    if attachments.upload(attachment)
      save
    else
      false
    end
  end

  def self.slug
    title.parameterize.pluralize
  end

  def can_be_published?
    !live?
  end

  def send_email_on_publish?
    update_type == "major"
  end

private

  def self.finder_schema
    @finder_schema ||= FinderSchema.new(document_type.pluralize)
  end

  def finder_schema
    self.class.finder_schema
  end
end
