class Section
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :base_path, :title, :summary, :body, :update_type

  validates :summary, presence: true
  validates :title, presence: true
  validates :body, presence: true, safe_html: true

  def initialize(params)
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @title = params.fetch(:title, nil)
    @summary = params.fetch(:summary, nil)
    @body = params.fetch(:body, nil)
    @publication_state = params.fetch(:publication_state, nil)
    self.manual_content_id = params.fetch(:manual_content_id)
    self.updated_at = params.fetch(:updated_at, nil)
    self.public_updated_at = params.fetch(:public_updated_at, nil)
  end

  %w{draft live redrafted}.each do |state|
    define_method("#{state}?") do
      publication_state == state
    end
  end

  def updated_at
    @updated_at ||= Time.zone.now
  end

  def updated_at=(timestamp)
    @updated_at = Time.parse(timestamp.to_s) unless timestamp.nil?
  end

  def public_updated_at
    @public_updated_at ||= Time.zone.now
  end

  def public_updated_at=(timestamp)
    @public_updated_at = Time.parse(timestamp.to_s) unless timestamp.nil?
  end

  def manual_content_id
    @manual_content_id
  end

  def manual_content_id=(manual_content_id)
    @manual_content_id = manual_content_id
  end

  def manual
    @manual ||= Manual.find(content_id: @manual_content_id)
  end

  def organisation_content_ids
    @organisation_content_ids
  end

  def organisation_content_ids=(organisation_content_ids)
    @organisation_content_ids = organisation_content_ids
  end

  OrganisationStruct = Struct.new(:content_id, :base_path, :title)

  def organisations
    @organisations ||= @organisation_content_ids.map { |content_id|
      payload = publishing_api.get_content(content_id).to_hash
      OrganisationStruct.new(payload["content_id"], payload["base_path"], payload["title"])
    }
  end

  def self.find(content_id:, manual_content_id: nil)
    section = self.from_publishing_api(content_id: content_id)

    if manual_content_id && section.manual_content_id != manual_content_id
      raise RecordNotFound.new("Section does exist, but not within the supplied manual")
    end

    section
  end

  def self.from_publishing_api(content_id:)
    content_item_response = self.publishing_api.get_content(content_id)

    raise RecordNotFound.new("Section not found") unless content_item_response

    content = content_item_response.to_hash
    payload = content.merge(
      self.publishing_api.get_links(content_id).to_hash
    )

    section = self.new(
      {
        content_id: payload["content_id"],
        title: payload["title"],
        summary: payload["description"],
        body: payload["details"]["body"],
        publication_state: payload["publication_state"],
        public_updated_at: payload["public_updated_at"],
        manual_content_id: payload["links"]["manual"].first
      }
    )

    section.base_path = payload["base_path"]
    section.update_type = payload["update_type"]

    if payload["links"]["organisations"]
      section.organisation_content_ids = payload["links"].fetch("organisations") || []
    end

    section
  end

private

  def publishing_api
    self.class.publishing_api
  end

  def self.publishing_api
    SpecialistPublisher.services(:publishing_api)
  end

  class RecordNotFound < StandardError; end
end
