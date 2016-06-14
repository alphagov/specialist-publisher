class GovspeakController < ApplicationController
  def preview
    skip_authorization

    govspeak_document = Govspeak::Document.new(params["bodyText"])
    render json: { renderedGovspeak: govspeak_document.to_html }
  end
end
