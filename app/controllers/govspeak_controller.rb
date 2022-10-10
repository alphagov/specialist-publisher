class GovspeakController < ApplicationController
  def preview
    skip_authorization

    json_attachments = JSON.parse(params["attachments"])

    attachments = json_attachments.map do |attachment|
      Attachment.new(attachment)
    end

    document = Document.new(
      { body: params["bodyText"],
        attachments: },
      [:attachments],
    )
    govspeak_presenter = GovspeakPresenter.new(document)
    govspeak_preview = govspeak_presenter.html_body
    render html: govspeak_preview.html_safe
  end
end
