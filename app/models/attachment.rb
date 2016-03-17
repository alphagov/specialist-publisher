require "gds_api/asset_manager"

class Attachment < Document
  attr_accessor :title, :file, :content_type, :url, :content_id, :created_at, :updated_at

  def initialize(params={})
    @title = params[:title]
    @file = params[:file]
    @content_type = params[:content_type]
    @url = params[:url]
    @content_id = params[:content_id] || SecureRandom.uuid
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
  end

end