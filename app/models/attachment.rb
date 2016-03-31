require "gds_api/asset_manager"

class Attachment < Document
  attr_accessor :title, :file, :content_type, :url, :content_id, :created_at, :updated_at
  attr_writer :changed

  def initialize(params = {})
    params = params.symbolize_keys
    @title = params[:title]
    @file = params[:file]
    @content_type = params[:content_type]
    @url = params[:url]
    @content_id = params[:content_id] || SecureRandom.uuid
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
    @changed = false
  end

  def update_attributes(new_params)
    new_params.each do |k, v|
      self.public_send(:"#{k}=", v)
    end
    self.changed = true
  end

  def changed?
    @changed
  end
end
