class Document
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActionView::Helpers::TextHelper
  include DateHelper
  include PublishingHelper

  attr_accessor(
    :content_id,
    :base_path,
    :title,
    :summary,
    :body,
    :format_specific_fields,
    :public_updated_at,
    :state,
    :bulk_published,
    :publication_state,
    :state_history,
    :change_history,
    :document_type,
    :attachments,
    :first_published_at,
    :previous_version,
    :temporary_update_type,
    :update_type,
    :warnings
  )

  def temporary_update_type
    !!@temporary_update_type
  end
  alias_method :temporary_update_type?, :temporary_update_type

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true, inline_attachments: true
  validates :update_type, presence: true, unless: :first_draft?
  validates :change_note, presence: true, if: :change_note_required?

  COMMON_FIELDS = [
    :base_path,
    :title,
    :summary,
    :body,
    :publication_state,
    :state_history,
    :public_updated_at,
    :first_published_at,
    :update_type,
    :bulk_published,
    :change_history,
    :temporary_update_type,
    :warnings
  ].freeze

  def self.policy_class
    DocumentPolicy
  end

  def initialize(params = {}, format_specific_fields = [])
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @format_specific_fields = format_specific_fields

    set_attributes(params, COMMON_FIELDS + format_specific_fields)

    @change_history ||= ChangeHistory.new
  end

  def set_attributes(attrs, keys = nil)
    keys = attrs.keys unless keys
    keys.each do |key|
      public_send(:"#{clean_key(key.to_s)}=", param_value(attrs, key))
    end
  end

  def bulk_published
    @bulk_published || false
  end

  def base_path
    if first_draft?
      @base_path = "#{finder_schema.base_path}/#{title.parameterize}"
    else
      @base_path
    end
    truncate(@base_path, length: 250, omission: "")
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
    draft? && first_published_at.blank?
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
      humanized_name = finder_schema.humanized_facet_name(key)
      humanized_value = finder_schema.humanized_facet_value(key, value)

      attributes.merge(humanized_name => humanized_value)
    end
  end

  def self.from_publishing_api(payload)
    DocumentBuilder.build(self, payload)
  end

  def self.all(page, per_page, q: nil)
    params = {
      publishing_app: "specialist-publisher",
      document_type: self.document_type,
      fields: [
        :base_path,
        :content_id,
        :last_edited_at,
        :title,
        :publication_state,
        :state_history,
      ],
      page: page,
      per_page: per_page,
      order: "-last_edited_at",
    }
    params[:q] = q if q.present?
    Services.publishing_api.get_content_items(params)
  end

  def self.find(content_id)
    begin
      response = Services.publishing_api.get_content(content_id)
    rescue GdsApi::HTTPNotFound
      raise RecordNotFound, "Document: #{content_id}"
    end

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

  def save(validate: true)
    return false if validate && !self.valid?

    self.update_type = 'major' if first_draft?

    presented_document = DocumentPresenter.new(self)
    presented_links = DocumentLinksPresenter.new(self)

    handle_remote_error do
      set_errors_on(self)
      Services.publishing_api.put_content(self.content_id, presented_document.to_json)
      Services.publishing_api.patch_links(self.content_id, presented_links.to_json)
    end
  end

  def publish
    return false unless publishable?

    handle_remote_error do
      if first_draft?
        @change_note = "First published."
        self.update_type = 'major'
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

      if previously_unpublished?
        AttachmentRestoreWorker.perform_async(self.content_id)
      end
    end
  end

  def unpublish
    handle_remote_error do
      Services.publishing_api.unpublish(content_id, type: 'gone')

      AttachmentDeleteWorker.perform_async(content_id)
      RummagerDeleteWorker.perform_async(base_path)
    end
  end

  def discard
    handle_remote_error do
      Services.publishing_api.discard_draft(content_id, previous_version: previous_version)
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

  def content_item_blocking_publish?
    warnings && warnings.has_key?("content_item_blocking_publish")
  end

  def self.finder_schema
    @finder_schema ||= FinderSchema.new(document_type.pluralize)
  end

private

  def finder_schema
    self.class.finder_schema
  end

  def previously_unpublished?
    ordered_states = state_history.sort.to_h.values
    ordered_states.last(2) == %w(unpublished draft)
  end

  def param_value(params, key)
    date_param_value(params, key) || params.fetch(key, nil)
  end

  def publishable?
    !content_item_blocking_publish?
  end
end
