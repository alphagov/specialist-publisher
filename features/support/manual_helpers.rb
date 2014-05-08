module ManualHelpers
  def create_manual(fields)
    visit new_manual_path
    fill_in_fields(fields)

    save_manual
  end

  def edit_manual(manual_title, new_fields)
    go_to_edit_page_for_manual(manual_title)
    fill_in_fields(new_fields)

    save_manual
  end

  def save_manual
    click_on "Save as draft"
  end

  def fill_in_fields(fields)
    fields.each do |field, text|
      fill_in field.to_s.humanize, with: text
    end
  end

  def check_manual_exists_with(attributes)
    visit manuals_path
    click_link attributes.fetch(:title)

    expect(page).to have_content(attributes.fetch(:summary))
  end

  def go_to_edit_page_for_manual(manual_title)
    visit manuals_path
    click_on(manual_title)
    click_on('Edit')
  end

  def check_for_errors_for_fields(field)
    page.should have_content("#{field.titlecase} can't be blank")
  end
end
