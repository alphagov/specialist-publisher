class Section
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :base_path, :title, :summary, :body, :update_type

  validates :summary, presence: true
  validates :title, presence: true
  validates :body, presence: true, safe_html: true

  def initialize(params = {})
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @title = params.fetch(:title, nil)
    @summary = params.fetch(:summary, nil)
    @body = params.fetch(:body, nil)
    @publication_state = params.fetch(:publication_state, nil)
    self.manual_content_id = params.fetch(:manual_content_id)
    self.updated_at = params.fetch(:updated_at, nil)
    self.public_updated_at = params.fetch(:public_updated_at, nil)
  end

  def base_path
    @base_path ||= "#{manual.base_path}/#{title.parameterize}"
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

  attr_accessor :manual_content_id

  def manual
    @manual ||= Manual.find(content_id: @manual_content_id)
  end

  attr_accessor :organisation_content_ids

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
      content_id: payload["content_id"],
      title: payload["title"],
      summary: payload["description"],
      body: payload["details"]["body"],
      publication_state: payload["publication_state"],
      public_updated_at: payload["public_updated_at"],
      manual_content_id: payload["links"]["manual"].first
    )

    section.base_path = payload["base_path"]
    section.update_type = payload["update_type"]

    if payload["links"]["organisations"]
      section.organisation_content_ids = payload["links"].fetch("organisations") || []
    end

    section
  end

  def update_manual_links
    manual_links = publishing_api.get_links(self.manual_content_id)['links']
    section_ids = manual_links.fetch('sections', [])

    if section_ids.include?(self.content_id)
      true
    else
      manual_link_request = publishing_api.patch_links(
        self.manual_content_id,
        links: { sections: section_ids << self.content_id }
      )
      manual_link_request.code == 200
    end
  end

  def update_attributes(new_attributes)
    new_attributes.each do |attribute, value|
      public_send(:"#{attribute}=", value)
    end
    save
  end

  def save
    if self.valid?
      presented_section = SectionPresenter.new(self).to_json

      presented_section_links = { links: { manual: [self.manual_content_id] } }
      begin
        item_request = publishing_api.put_content(self.content_id, presented_section)
        section_link_request = publishing_api.patch_links(self.content_id, presented_section_links)
        item_request.code == 200 && update_manual_links && section_link_request.code == 200
      rescue GdsApi::HTTPErrorResponse => e
        Airbrake.notify(e)
        false
      end
    else
      false
    end
  end

private

  def publishing_api
    self.class.publishing_api
  end

  def self.publishing_api
    SpecialistPublisher.services(:publishing_api)
  end

  class RecordNotFound < StandardError;
  end
end
