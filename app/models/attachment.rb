require "gds_api/asset_manager"

class Attachment < Document
  attr_accessor :title, :file, :content_type, :url, :content_id, :created_at, :updated_at

  def initialize(params = {})
    params = params.symbolize_keys
    @title = params[:title]
    @file = params[:file]
    @content_type = params[:content_type]
    @url = params[:url]
    @content_id = params[:content_id] || SecureRandom.uuid
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
  end

  def update_attributes(new_params)
    new_params.each do |k, v|
      self.public_send(:"#{k}=", v)
    end
  end

  def self.all_from_publishing_api(payload)
    return nil unless payload.fetch('details', {}).key?('attachments')
    payload['details']['attachments'].map { |attachment| Attachment.new(attachment) }
  end

  def upload
    response = Services.asset_api.create_asset(file: @file)
    @url = response.file_url
    true
  rescue GdsApi::BaseError => e
    Airbrake.notify(e)
    false
  end
end
