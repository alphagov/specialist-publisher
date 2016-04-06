class Document
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :base_path, :title, :summary, :body, :format_specific_fields, :public_updated_at, :state, :bulk_published, :publication_state, :change_note, :document_type, :attachments

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
  ]

  def initialize(params = {}, format_specific_fields = [])
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @format_specific_fields = format_specific_fields

    (COMMON_FIELDS + format_specific_fields).each do |field|
      public_send(:"#{field.to_s}=", params.fetch(field, nil))
    end
  end

  def base_path
    @base_path ||= "#{finder_schema.base_path}/#{title.parameterize}"
  end

  def publishing_api_document_type
    self.class.publishing_api_document_type
  end

  def self.publishing_api_document_type
    # This is the string sent as `document_type` in the `details["metadata"]` hash
    # and should be redefined within the child classes
    raise NotImplementedError
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

  def self.from_publishing_api(payload)
    document = self.new(
      content_id: payload['content_id'],
      title: payload['title'],
      summary: payload['description'],
      body: payload['details']['body'],
      publication_state: payload['publication_state'],
      public_updated_at: payload['public_updated_at']
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

  def self.all
    # The current version of this method is a result of the Publishing API
    # returning the `details` field as an empty hash. As such, we get the
    # content_id of all `specialist_document`s, then request the individual
    # payload for each, which allows us to construct the real object.
    #
    # When the Publishing API is fixed and `details` is returned, this method
    # will request all the required fields and the map will call
    # `self.from_publishing_api` itself.
    response = self.publishing_api.get_content_items(
      document_type: self.publishing_api_document_type,
      fields: [
        :base_path,
        :content_id,
        :public_updated_at,
        :title,
        :publication_state,
      ]
    ).to_ostruct

    response.results
  end

  def self.find(content_id)
    response = publishing_api.get_content(content_id)

    if response
      self.from_publishing_api(response.to_hash)
    else
      raise RecordNotFound
    end
  end

  class RecordNotFound < StandardError; end

  def save!
    if self.valid?
      self.public_updated_at = Time.zone.now if self.update_type == 'major'

      presented_document = DocumentPresenter.new(self)
      presented_links = DocumentLinksPresenter.new(self)

      begin
        item_request = publishing_api.put_content(self.content_id, presented_document.to_json)
        links_request = publishing_api.patch_links(self.content_id, presented_links.to_json)

        item_request.code == 200 && links_request.code == 200
      rescue GdsApi::HTTPErrorResponse => e
        Airbrake.notify(e)

        false
      end
    else
      raise RecordNotSaved
    end
  end

  class RecordNotSaved < StandardError; end

  def publish!
    indexable_document = SearchPresenter.new(self)

    begin
      update_type = self.update_type || 'major'
      publish_request = publishing_api.publish(content_id, update_type)
      rummager_request = rummager.add_document(
        search_document_type,
        base_path,
        indexable_document.to_json,
      )

      if self.update_type == "major"
        email_alert_api.send_alert(EmailAlertPresenter.new(self).to_json)
      end

      publish_request.code == 200 && rummager_request.code == 200
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)
    end
  end

  def withdraw!
    gone_content_id = SecureRandom.uuid
    presented_document = WithdrawPresenter.new(gone_content_id, self.base_path)

    begin
      item_request = publishing_api.put_content(gone_content_id, presented_document.to_json)
      publish_request = publishing_api.publish(gone_content_id, update_type)

      item_request.code == 200 && publish_request.code == 200
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)

      false
    end
  end

  def find_attachment(attachment_content_id)
    self.attachments.detect { |attachment| attachment.content_id == attachment_content_id }
  end

private

  def email_alert_api
    SpecialistPublisher.services(:email_alert_api)
  end

  def rummager
    SpecialistPublisher.services(:rummager)
  end

  def publishing_api
    self.class.publishing_api
  end

  def self.publishing_api
    SpecialistPublisher.services(:publishing_api)
  end

  def self.finder_schema
    @finder_schema ||= FinderSchema.new(publishing_api_document_type.pluralize)
  end

  def finder_schema
    self.class.finder_schema
  end
end
