module ManualHelpers
  def create_manual(fields)
    visit new_manual_path
    fill_in_fields(fields)

    save_as_draft
  end

  def create_manual_document(manual_title, fields)
    go_to_manual_page(manual_title)
    click_on "Add Section"

    fill_in_fields(fields)

    save_as_draft
  end

  def edit_manual(manual_title, new_fields)
    go_to_edit_page_for_manual(manual_title)
    fill_in_fields(new_fields)

    save_as_draft
  end

  def edit_manual_document(manual_title, section_title, new_fields)
    go_to_manual_page(manual_title)
    click_on section_title
    click_on "Edit"
    fill_in_fields(new_fields)

    save_as_draft
  end

  def save_as_draft
    click_on "Save as draft"
  end

  def check_manual_exists_with(attributes)
    go_to_manual_page(attributes.fetch(:title))
    expect(page).to have_content(attributes.fetch(:summary))
  end

  def check_manual_document_exists_with(manual_title, attributes)
    go_to_manual_page(manual_title)
    click_on(attributes.fetch(:title))

    attributes.values.each do |attr_val|
      expect(page).to have_content(attr_val)
    end
  end

  def go_to_edit_page_for_manual(manual_title)
    go_to_manual_page(manual_title)
    click_on('Edit Manual')
  end

  def check_for_errors_for_fields(field)
    page.should have_content("#{field.titlecase} can't be blank")
  end

  def go_to_manual_page(manual_title)
    visit manuals_path
    click_link manual_title
  end

  def check_manual_slug_was_reserved(slug)
    expect(fake_panopticon).to have_received(:create_artefact!)
      .with(
        hash_including(
          slug: slug,
          kind: "manual",
          rendering_app: "manuals-frontend",
        )
      )
  end

  def check_manual_document_slug_was_reserved(slug)
    expect(fake_panopticon).to have_received(:create_artefact!)
      .with(
        hash_including(
          slug: slug,
          kind: "manual-section",
          rendering_app: "manuals-frontend",
        )
      )
  end

  def check_manual_was_published_to_panopticon(slug, attrs)
    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(
        panopticon_id_for_slug(slug),
        hash_including(
          name: attrs.fetch(:title),
          slug: slug,
          state: "live",
          kind: "manual",
          rendering_app: "manuals-frontend",
        )
      )
  end

  def check_manual_section_was_published_to_panopticon(slug, attrs)
    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(
        panopticon_id_for_slug(slug),
        hash_including(
          name: attrs.fetch(:title),
          slug: slug,
          state: "live",
          kind: "manual-section",
          rendering_app: "manuals-frontend",
        )
      )
  end

  def check_manual_is_published_to_content_api(attrs)
    check_for_published_document_with(attrs.except(:body))
  end

  def check_manual_document_is_published_to_content_api(attrs)
    check_for_published_document_with(attrs.except(:body))
  end

  def check_manual_and_documents_were_published(manual_slug, manual_attrs, document_slug, document_attrs)
    check_manual_was_published_to_panopticon(manual_slug, manual_attrs)
    check_manual_section_was_published_to_panopticon(document_slug, document_attrs)

    check_manual_is_published_to_content_api(manual_attrs)
    check_manual_document_is_published_to_content_api(document_attrs)
  end
end
