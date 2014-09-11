require "govspeak"
require "plek"

class SafeHtmlValidator < ActiveModel::EachValidator
  ALLOWED_IMAGE_HOSTS = [
    # URLs for the local environment
    URI.parse(Plek.new.website_root).host, # eg www.preview.alphagov.co.uk
    URI.parse(Plek.new.asset_root).host,   # eg assets-origin.preview.alphagov.co.uk

    # Hardcode production URLs so that content copied from production is valid
    "www.gov.uk",
    "assets.digital.cabinet-office.gov.uk"
  ]

  def validate_each(record, attribute, value)
    unless safe_html?(value)
      record.errors.add(attribute, error_message)
    end
  end

private
  def safe_html?(html_string)
    Govspeak::Document.new(html_string).valid?(allowed_image_hosts: ALLOWED_IMAGE_HOSTS)
  end

  def error_message
    options[:message] || "cannot include invalid Govspeak, invalid HTML, any JavaScript or images hosted on sites except for #{ALLOWED_IMAGE_HOSTS.join(", ")}"
  end
end
