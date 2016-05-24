class Manual
  include ActiveModel::Model
  include ActiveModel::Validations
  include PublishingHelper

  #publishing-api will return per_page default of 50 items. ALL variable is set to high number to return all manuals until pagination is properly implemented, else user would only see 50 manuals.

  attr_accessor :content_id, :base_path, :title, :summary, :body, :publication_state, :update_type

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, safe_html: true

  def initialize(params = {})
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @title = params.fetch(:title, nil)
    @summary = params.fetch(:summary, nil)
    @body = params.fetch(:body, nil)
    @publication_state = params.fetch(:publication_state, nil)
    self.updated_at = params.fetch(:updated_at, nil)
    self.public_updated_at = params.fetch(:public_updated_at, nil)
  end

  def base_path
    @base_path ||= "/guidance/#{title.parameterize}"
  end

  %w{draft live redrafted}.each do |state|
    define_method("#{state}?") do
      publication_state == state
    end
  end

  def published?
    live? || redrafted?
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

  attr_accessor :section_content_ids

  def sections
    @sections ||= @section_content_ids.map { |content_id|
      Section.find(content_id: content_id)
    }
  end

  attr_accessor :organisation_content_ids

  OrganisationStruct = Struct.new(:content_id, :base_path, :title)

  def organisations
    @organisations ||= @organisation_content_ids.map { |content_id|
      payload = publishing_api.get_content(content_id).to_hash
      OrganisationStruct.new(payload["content_id"], payload["base_path"], payload["title"])
    }
  end

  def self.all
    # Fetch individual payloads and links for each `manual`
    results = get_content_items.results
    results.each do |item|
      item.links = publishing_api.get_links(item.content_id).to_hash["links"]
    end
    # Deserialize the payloads into real Objects and return them
    results.map { |payload| self.from_publishing_api(payload) }
  end

  def self.where(organisation_content_id:)
    # Fetch individual links for each `manual`
    payloads = get_content_items.results.map { |item|
      publishing_api.get_links(item.content_id).to_ostruct
    }

    # Select ones which have the same `content_id` as the `organisation_content_id` arguement
    payloads.select! { |payload| payload.links.organisations.present? }
    payloads.select! { |payload| payload.links.organisations.include?(organisation_content_id) }

    # Fetch the content_id
    payloads = payloads.map { |payload|
      content = publishing_api.get_content(payload.content_id).to_hash
      content.deep_merge!(payload.links)
    }

    # Deserialize the payloads into real Objects and return them
    payloads.map { |payload| self.from_publishing_api(payload) }
  end

  def self.find(content_id:, organisation_content_id: nil)
    if organisation_content_id
      links_response = publishing_api.get_links(content_id)

      if links_response.to_ostruct.organisations.include?(organisation_content_id)
        content_response = publishing_api.get_content(content_id)

        content = content_response.to_hash
        payload = content.deep_merge(links.to_hash)
      else
        raise RecordNotFound
      end
    else
      content_response = publishing_api.get_content(content_id)
      links_response = publishing_api.get_links(content_id)

      if content_response && links_response
        content = content_response.to_hash
        links = links_response.to_hash

        payload = content.deep_merge(links)
      else
        raise RecordNotFound
      end
    end

    self.from_publishing_api(payload)
  end

  class RecordNotFound < StandardError; end

  def self.from_publishing_api(payload)
    manual = self.new(
      content_id: payload["content_id"],
      title: payload["title"],
      summary: payload["description"],
      body: payload["details"]["body"],
      publication_state: payload["publication_state"],
      public_updated_at: payload["public_updated_at"]
    )

    manual.base_path = payload["base_path"]
    manual.update_type = payload["update_type"]
    if payload["links"]
      manual.organisation_content_ids = payload["links"].fetch("organisations", [])
      manual.section_content_ids = payload["links"].fetch("sections", [])
    end

    manual
  end

  def publish_tasks
    # TODO Implment sidekiq
    []
  end

  def self.get_content_items
    self.publishing_api.get_content_items(
      document_type: "manual",
      fields: [
          :content_id,
          :description,
          :title,
          :details,
          :public_updated_at,
          :publication_state,
          :base_path,
          :update_type
      ],
      per_page: max_numbers_of_manuals
    ).to_ostruct
  end

  def self.max_numbers_of_manuals
    10
  end

  def update_attributes(new_attributes)
    new_attributes.each do |attribute, value|
      public_send(:"#{attribute}=", value)
    end
    save
  end

  def save
    if self.valid?
      presented_manual = ManualPresenter.new(self)
      presented_links = ManualLinksPresenter.new(self)
      handle_remote_error do
        publishing_api.put_content(self.content_id, presented_manual.to_json)
        publishing_api.patch_links(self.content_id, presented_links.to_json)
      end
    else
      false
    end
  end

  def can_be_published?
    sections.any?
  end

private

  def publishing_api
    self.class.publishing_api
  end

  def self.publishing_api
    Services.publishing_api
  end
end
