require 'spec_helper'

describe GovspeakPresenter do
  it "should render html and Govspeak when a Govspeak string is provided" do
    input_govspeak = "^callout test^"
    rendered_html = "\n<div role=\"note\" aria-label=\"Information\" class=\"application-notice info-notice\">\n<p>callout test</p>\n</div>\n"
    presented_content = [{ content_type: "text/govspeak", content: input_govspeak },
                         { content_type: "text/html", content: rendered_html }]

    expect(GovspeakPresenter.present(input_govspeak)).to eq(presented_content)
  end
end
