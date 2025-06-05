module Legacy::UrlHelper
  include ::UrlHelper

  def preview_draft_link_for_legacy(document)
    link_to "Preview draft", draft_url_for(document)
  end

  def view_on_website_link_for_legacy(document)
    link_to "View on website", public_url_for(document)
  end
end
