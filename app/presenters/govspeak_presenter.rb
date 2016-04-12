module GovspeakPresenter
  class << self
    def present(govspeak)
      [
        { content_type: "text/govspeak", content: govspeak },
        { content_type: "text/html", content: html(govspeak) }
      ]
    end

  private

    def html(govspeak)
      Govspeak::Document.new(govspeak).to_html
    end
  end
end
