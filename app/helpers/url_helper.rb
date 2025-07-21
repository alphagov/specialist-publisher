module UrlHelper
  def public_url_for(document)
    URI.join(Plek.website_root, document.base_path, cachebust_query_string).to_s
  end

  def draft_url_for(document)
    URI.join(Plek.external_url_for("draft-origin"), document.base_path, cachebust_query_string).to_s
  end

private

  def cachebust_query_string
    "?cachebust=#{Time.zone.now.getutc.to_i}"
  end
end
