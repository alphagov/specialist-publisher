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

  %w{draft live redrafted}.each do |state|
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

  def change_note_required?
    update_type == 'major' && published?
  end

  def change_history
    @change_history ||= []
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

    document.attachments = Attachment.all_from_publishing_api(payload)
    # Persist the rest of the change_history on the document
    # if the document is live or redrafted
    document.change_history = payload['details']['change_history'].map(&:to_h) if document.published?

    document.format_specific_fields.each do |field|
      document.public_send(:"#{field.to_s}=", payload['details']['metadata'][field.to_s])
    end

    document
  end

  def public_updated_at
    @public_updated_at ||= Time.zone.now
  end

  def public_updated_at=(timestamp)
    @public_updated_at = Time.parse(timestamp.to_s) unless timestamp.nil?
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

    if response
      self.from_publishing_api(response.to_hash)
    else
      raise RecordNotFound
    end
  end

  class RecordNotFound < StandardError; end

  def save
    return false unless self.valid?

    self.public_updated_at = Time.zone.now if self.update_type == 'major'

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
      Services.publishing_api.publish(content_id, update_type)

      published_document = self.class.find(self.content_id)
      indexable_document = SearchPresenter.new(published_document)

      Services.rummager.add_document(
        search_document_type,
        base_path,
        indexable_document.to_json,
      )

      if send_email_on_publish?
        Services.email_alert_api.send_alert(EmailAlertPresenter.new(self).to_json)
      end
    end
  end

  def find_attachment(attachment_content_id)
    self.attachments.detect { |attachment| attachment.content_id == attachment_content_id }
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

  def self.attachments(payload)
    payload.details.attachments.map { |attachment| Attachment.new(attachment) }
  end

  def self.finder_schema
    @finder_schema ||= FinderSchema.new(document_type.pluralize)
  end

  def finder_schema
    self.class.finder_schema
  end
end
