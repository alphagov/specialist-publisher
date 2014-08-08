class FootnotesSectionHeadingRenderer < SimpleDelegator
  def body
    document.body.gsub(footnote_open_tag, "#{heading_tag}\\&")
  end

  def attributes
    document.attributes.merge(
      body: body,
    )
  end

private
  def footnote_open_tag
    '<div class="footnotes">'
  end

  def heading_tag
    '<h2 id="footnotes">Footnotes</h2>'
  end

  def document
    __getobj__
  end
end
