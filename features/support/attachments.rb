def add_attachment_to_case(document_title)
  click_on document_title
  click_on "Add attachment"
  fill_in "Title", with: "My attachment"
  attach_file "File", File.expand_path("../fixtures/greenpaper.pdf", File.dirname(__FILE__))
  click_on "Save attachment"
end

def check_for_an_attachment
  page.should have_content("My attachment")
  page.should have_content("[InlineAttachment:greenpaper.pdf]")
end