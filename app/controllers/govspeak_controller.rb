class GovspeakController < ApplicationController
  def preview
    skip_authorization

    govspeak_preview = Govspeak::Document.new(params["bodyText"]).to_html
    render html: govspeak_preview.html_safe
  end
end
