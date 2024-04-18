require "services"

class Document
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActionView::Helpers::TextHelper
  include DateHelper
  include PublishingHelper

  attr_reader :update_type
  attr_writer(
    :temporary_update_type,
    :bulk_published,
    :base_path,
    :document_type,
    :links,
  )
  attr_accessor(
    :content_id,
    :locale,
    :title,
    :summary,
    :body,
    :format_specific_fields,
    :last_edited_at,
    :public_updated_at,
    :state,
    :publication_state,
    :state_history,
    :first_published_at,
    :previous_version,
    :warnings,
  )

  def temporary_update_type
    @temporary_update_type.present?
  end

  alias_method :temporary_update_type?, :temporary_update_type

  validates :title, presence: true
  validates :summary, presence: true, unless: :protected_food_drink_name?
  validates :body, presence: true, safe_html: true, inline_attachments: true
  validates :update_type, presence: true, unless: :first_draft?
  validates :change_note, presence: true, if: :change_note_required?

  COMMON_FIELDS = %i[
    locale
    base_path
    title
    summary
    body
    publication_state
    state_history
    last_edited_at
    public_updated_at
    first_published_at
    update_type
    bulk_published
    temporary_update_type
    warnings
  ].freeze

  AIR_ACCIDENTS_AND_SERIOUS_INCIDENTS_TAXON_ID = "951ece54-c6df-4fbc-aa18-1bc629815fe2".freeze
  ALERTS_AND_RECALLS_TAXON_ID = "51bbdf23-292a-4b74-8a66-f7db6b93b163".freeze
  ASYLUM_DECISIONS_AND_APPEALS_TAXON_ID = "e1d2032c-6a59-4a1a-919c-dc149847dffb".freeze
  BREXIT_TAXON_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze
  BUSINESS_FINANCE_AND_SUPPORT_TAXON_ID = "ccfc50f5-e193-4dac-9d78-50b3a8bb24c5".freeze
  COMPETITION_TAXON_ID = "8db04387-9076-4287-ab46-6a6695b593d7".freeze
  COUNTRYSIDE_TAXON_ID = "9129d716-365b-44ba-9856-383423fe1e41".freeze
  COURTS_SENTENCING_AND_TRIBUNALS_TAXON_ID = "357110bb-cbc5-4708-9711-1b26e6c63e86".freeze
  DIGITAL_SERVICE_STANDARD_TAXON_ID = "84630bce-4c1c-4406-a38a-e8c41967b8f7".freeze
  EUROPEAN_FUNDS_TAXON_ID = "2894668d-0c21-491a-9069-a271e67f6025".freeze
  INTERNATIONAL_AID_AND_DEVELOPMENT_TAXON_ID = "9fb30a53-70fb-4f1c-878b-0064b202d1ba".freeze
  MARITIME_ACCIDENTS_AND_SERIOUS_INCIDENTS_TAXON_ID = "7a5e878e-2b0f-4c3f-9079-586590a1a194".freeze
  RAIL_ACCIDENTS_AND_SERIOUS_INCIDENTS_TAXON_ID = "c6a19bb4-1264-4abe-9f1c-6c30f8dea5f7".freeze

  def self.policy_class
    DocumentPolicy
  end

  def taxons
    []
  end

  def initialize(params = {}, format_specific_fields = [])
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @format_specific_fields = format_specific_fields

    set_attributes(params, COMMON_FIELDS + format_specific_fields)
  end

  def set_attributes(attrs, keys = nil)
    keys ||= attrs.keys
    keys.each do |key|
      public_send(:"#{clean_key(key.to_s)}=", param_value(attrs, key))
    end
  end

  def to_h
    super.merge(links:)
  end

  def bulk_published
    @bulk_published || false
  end

  def base_path
    if first_draft?
      @base_path = "#{finder_schema.base_path}/#{title.to_url}"
    else
      @base_path
    end
    truncate(@base_path, length: 250, omission: "")
  end

  def rendering_app
    "government-frontend"
  end

  def document_type
    self.class.document_type
  end

  def self.document_type
    to_s.underscore
  end

  delegate :format, to: :finder_schema

  def phase
    "live"
  end

  def draft?
    publication_state == "draft" || publication_state.nil?
  end

  def published?
    publication_state == "published"
  end

  def unpublished?
    publication_state == "unpublished"
  end

  def first_draft?
    draft? && state_history_one_or_shorter?
  end

  def state_history_one_or_shorter?
    state_history.nil? || state_history.size < 2
  end

  def change_note_required?
    return unless update_type == "major"

    !first_draft?
  end

  def change_note
    return unless update_type == "major"

    @change_note
  end

  def change_note=(note)
    return unless update_type == "major"

    @change_note = note
  end

  def update_type=(update_type)
    @previous_update_type = @update_type
    @update_type = update_type
  end

  def users
    content_item.users || []
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

  delegate :organisations, to: :finder_schema

  def schema_editing_organisations
    finder_schema.editing_organisations
  end

  def self.schema_organisations
    finder_schema.organisations
  end

  def self.schema_editing_organisations
    new.schema_editing_organisations
  end

  def format_specific_metadata
    format_specific_fields.index_with do |field|
      send(field)
    end
  end

  def humanized_attributes
    format_specific_metadata.inject({}) do |attributes, (key, value)|
      humanized_name = finder_schema.humanized_facet_name(key)
      humanized_value = finder_schema.humanized_facet_value(key, value)

      attributes.merge(humanized_name => humanized_value)
    end
  end

  def self.from_publishing_api(payload)
    DocumentBuilder.build(self, payload)
  end

  def self.all(page, per_page, query: nil, organisation: nil)
    AllDocumentsFinder.all(page, per_page, query, document_type, organisation)
  end

  def self.find_each(&block)
    AllDocumentsFinder.find_each(self, &block)
  end

  def self.find(content_id, locale, version: nil)
    DocumentFinder.find(self, content_id, locale, version:)
  end

  def save(validate: true)
    return false if validate && !valid?

    handle_remote_error(self) do
      DocumentSaver.save(self)
    end
  end

  def publish
    return false unless publishable?

    handle_remote_error(self) do
      DocumentPublisher.publish(self)
    end
  end

  def unpublish(alternative_path = nil)
    handle_remote_error(self) do
      DocumentUnpublisher.unpublish(content_id, locale, base_path, alternative_path)
    end
  end

  def discard
    handle_remote_error(self) do
      Services.publishing_api.discard_draft(content_id, previous_version:)
    end
  end

  def attachments=(attachments)
    @attachments = AttachmentCollection.new(attachments)
  end

  def has_attachment?(attachment)
    find_attachment(attachment.content_id).present?
  end

  def attachments
    @attachments ||= AttachmentCollection.new
  end

  def delete_attachment(attachment)
    if attachments.remove(attachment)
      save(validate: false)
    else
      false
    end
  end

  def upload_attachment(attachment)
    if attachments.upload(attachment)
      save(validate: false)
    else
      false
    end
  end

  def update_attachment(attachment)
    if attachments.update(attachment)
      save(validate: false)
    else
      false
    end
  end

  def set_temporary_update_type!
    return if update_type

    self.temporary_update_type = true
    self.update_type = "minor"
  end

  def self.slug
    title.parameterize.pluralize
  end

  def content_id_and_locale
    "#{content_id}:#{locale}"
  end

  def send_email_on_publish?
    update_type == "major"
  end

  # This is set to nil for all non-urgent emails.
  # Override to true for urgent email handling for a specific format.
  # Urgent emails are sent immediately to all users,
  # regardless of how frequently the users are set to get email updates
  #
  # Sending false will force overriding of topic defaults, and should
  # only be done where we explicitly want an email to be non urgent and
  # not to fallback to gov delivery defaults
  def urgent
    nil
  end

  def email_footnote
    nil
  end

  def content_item_blocking_publish?
    warnings && warnings.key?("content_item_blocking_publish")
  end

  def self.finder_schema
    @finder_schema ||= FinderSchema.new(document_type.pluralize)
  end

  def links
    {
      "finder": [finder_schema.content_id],
    }
  end

  def route_type
    "exact"
  end

  def self.exportable?
    false
  end

  def self.has_organisations?
    false
  end

  def custom_error_message_fields
    []
  end

private

  def finder_schema
    self.class.finder_schema
  end

  def param_value(params, key)
    date_param_value(params, key) || params.fetch(key, nil)
  end

  def publishable?
    !content_item_blocking_publish?
  end

  def protected_food_drink_name?
    document_type == "protected_food_drink_name"
  end
end
