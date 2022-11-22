module UrlHelper
  def preview_draft_link_for(document)
    link_to "Preview draft", draft_url_for(document)
  end

  def view_on_website_link_for(document)
    link_to "View on website", public_url_for(document)
  end

  def public_url_for(document)
    URI.join(Plek.website_root, document.base_path, cachebust_query_string).to_s
  end

  def draft_url_for(document)
    URI.join(Plek.external_url_for("draft-origin"), document.base_path, cachebust_query_string).to_s
  end

  def cachebust_query_string
    "?cachebust=#{Time.zone.now.getutc.to_i}"
  end
end
