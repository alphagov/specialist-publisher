module GovspeakHelper
  def govspeak_to_html(govspeak)
    document = Document.new({ body: govspeak })
    GovspeakPresenter.new(document)
                     .html_body
                     .html_safe
  end
end
