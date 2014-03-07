def add_attachment_to_case(document_title)
  click_on document_title
  click_on "Add attachment"
  fill_in "Title", with: "My attachment"
  attach_file "File", File.expand_path("../fixtures/greenpaper.pdf", File.dirname(__FILE__))
  click_on "Save attachment"
end

def check_for_an_attachment
  within(".attachments") do
    expect(page).to have_content("My attachment")
    expect(page).to have_content("[InlineAttachment:greenpaper.pdf]")
  end
end

def copy_embed_code_for_attachment_and_paste_into_body(title)
  snippet = within(".attachments") do
    page
      .find("li", text: /#{title}/)
      .find("span.snippet")
      .text
  end

  body_text = find("#specialist_document_body").value
  fill_in("Body", with: body_text + snippet)
end

def check_preview_contains_attachment_link(title)
  within(".preview") do
    expect(page).to have_css("a", text: title)
  end
end
