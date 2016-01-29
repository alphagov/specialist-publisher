class Manual
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :base_path, :title, :summary, :body, :public_updated_at, :publication_state

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, safe_html: true

  def initialize(payload)

  end
end
