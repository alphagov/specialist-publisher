module AccessControlHelpers
  def check_manual_visible(title)
    expect(page).to have_content(title)
  end

  def check_manual_not_visible(title)
    expect(page).to_not have_content(title)
  end

  def check_document_link_not_visible
    expect(page).not_to have_css("a", text: "Documents")
  end

  def check_page_for_content(content)
    expect(page).to have_content(content)
  end
end
RSpec.configuration.include AccessControlHelpers, type: :feature
