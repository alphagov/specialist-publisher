require "gds_api/asset_manager"

class Attachment < Document
  attr_accessor :title, :file, :content_type, :url, :content_id, :created_at, :updated_at

  def self.all_from_publishing_api(payload)
    return [] unless payload.fetch('details', {}).key?('attachments')
    payload['details']['attachments'].map { |attachment| Attachment.new(attachment) }
  end

  def initialize(params = {})
    params = params.symbolize_keys
    @title = extract_title(params)
    @file = params[:file]
    @content_type = params[:content_type]
    @url = params[:url]
    @content_id = params[:content_id] || SecureRandom.uuid
    @created_at = params[:created_at]
    @updated_at = params[:updated_at]
    @params = params
  end

  def update_attributes(new_params)
    new_params.each do |k, v|
      self.public_send(:"#{k}=", v)
    end
  end

  def extract_title(params)
    if params[:title].blank?
      if params[:url]
        separated_url = params[:url].split('/')
        filename = separated_url[separated_url.length - 1]
        remove_extension_from_filename(filename)
      elsif params[:file]
        remove_extension_from_filename(params[:file].original_filename)
      end
    else
      params[:title]
    end
  end

  def upload
    response = Services.asset_api.create_asset(file: @file)
    @url = response.file_url
    true
  rescue GdsApi::BaseError => e
    Airbrake.notify(e)
    false
  end

  def remove_extension_from_filename(filename)
    filename.split('.').first
  end

  def snippet
    if url
      "[InlineAttachment:#{url.split('/').last}]"
    else
      "[InlineAttachment:#{content_id}]"
    end
  end
end
