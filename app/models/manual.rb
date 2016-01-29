class Manual
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :base_path, :title, :summary, :body, :public_updated_at, :publication_state, :update_type

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, safe_html: true

  def initialize(params)
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @title = params.fetch(:title, nil)
    @summary = params.fetch(:summary, nil)
    @body = params.fetch(:body, nil)
    @publication_state = params.fetch(:publication_state, nil)
    @public_updated_at = params.fetch(:public_updated_at, nil)
  end

  %w{draft live redrafted}.each do |state|
    define_method("#{state}?") do
      publication_state == state
    end
  end

  def self.all
    response = self.publishing_api.get_content_items(
      content_format: "manual",
      fields: [
        :content_id,
      ]
    ).to_ostruct

    # Fetch individual payloads for each `manual`
    payloads = response.map { |payload| publishing_api.get_content(payload.content_id).to_ostruct }

    # Deserialize the payloads into real Objects and return them
    payloads.map { |payload| self.from_publishing_api(payload) }
  end

  def self.from_publishing_api(payload)
    manual = self.new(
      {
        content_id: payload.content_id,
        title: payload.title,
        summary: payload.description,
        body: payload.details.body,
        publication_state: payload.publication_state,
        public_updated_at: payload.public_updated_at,
      }
    )

    manual.base_path = payload.base_path
    manual.update_type = payload.update_type

    manual
  end

  def publishing_api
    self.class.publishing_api
  end

  def self.publishing_api
    SpecialistPublisher.services(:publishing_api)
  end

end
