require "govspeak"
require "plek"

class SafeHtmlValidator < ActiveModel::EachValidator
  ALLOWED_IMAGE_HOSTS = [
    # URLs for the local environment
    URI(Plek.website_root).host, # eg www.integration.publishing.service.gov.uk
    URI(Plek.asset_root).host,   # eg assets.integration.publishing.service.gov.uk

    # Hardcode production URLs so that content copied from production is valid
    "www.gov.uk",
    "assets.publishing.service.gov.uk",
  ].freeze

  def validate_each(record, attribute, value)
    record.errors.add(attribute, error_message) unless safe_html?(value)
  end

private

  def safe_html?(html_string)
    Govspeak::Document.new(html_string).valid?(allowed_image_hosts: ALLOWED_IMAGE_HOSTS)
  end

  def error_message
    options[:message] || "cannot include invalid Govspeak, invalid HTML, any JavaScript or images hosted on sites except for #{ALLOWED_IMAGE_HOSTS.join(', ')}"
  end
end
