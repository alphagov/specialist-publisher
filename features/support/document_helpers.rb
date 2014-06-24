module DocumentHelpers
  def create_aaib_report(*args)
    visit new_aaib_report_path
    create_document(*args)
  end

  def create_cma_case(*args)
    visit new_specialist_document_path
    create_document(*args)
  end

  def create_document(fields, save: true, publish: false)
    fill_in_fields(fields)

    if save
      save_document
    end

    if save && publish
      publish_document
    end
  end

  def save_document
    click_on "Save as draft"
  end

  def publish_document
    click_on "Publish"
  end

  def check_slug_registered_with_panopticon_with_correct_organisation(slug, organisation_ids = [])
    expect(fake_panopticon).to have_received(:create_artefact!)
      .with(hash_including(slug: slug, organisation_ids: organisation_ids))
  end

  def check_document_exists_with(attributes)
    go_to_show_page_for_document(attributes.fetch(:title))

    attributes.except(:body).each do |_, value|
      expect(page).to have_content(value)
    end
  end

  def check_document_does_not_exist_with(attributes)
    refute SpecialistDocumentEdition.exists?(conditions: attributes)
  end

  def check_aaib_report_exists_with(attributes)
    go_to_show_page_for_aaib_report(attributes.fetch(:title))

    attributes.except(:body).each do |_, value|
      expect(page).to have_content(value)
    end
  end

  def check_aaib_report_does_not_exist_with(attributes)
    refute SpecialistDocumentEdition.exists?(conditions: attributes)
  end

  def go_to_aaib_report_index
    unless current_path == aaib_reports_path
      visit(aaib_reports_path)
    end
  end

  def go_to_document_index
    unless current_path == specialist_documents_path
      visit(specialist_documents_path)
    end
  end

  def go_to_show_page_for_aaib_report(aaib_report_title)
    raise "Cannot find aaib report nil title" if aaib_report_title.nil?
    go_to_aaib_report_index
    click_link aaib_report_title
  end

  def go_to_show_page_for_document(document_title)
    raise "Cannot find document nil title" if document_title.nil?
    go_to_document_index
    click_link document_title
  end

  def go_to_edit_page_for_document(document_title)
    go_to_show_page_for_document(document_title)

    click_on "Edit"
  end

  def go_to_edit_page_for_aaib_report(aaib_report_title)
    go_to_show_page_for_aaib_report(aaib_report_title)

    click_on "Edit"
  end

  def update_title_and_republish(current_title, args)
    updated_title = args.fetch(:to)

    go_to_edit_page_for_document(current_title)

    fill_in_fields(
      title: updated_title,
    )

    save_document
    publish_document
  end

  def check_for_unchanged_slug(title, expected_slug)
    go_to_show_page_for_document(title)

    expect(page).to have_link(expected_slug)
  end

  def check_for_published_document_with(attrs)
    expect(
      RenderedSpecialistDocument.where(attrs)
    ).not_to be_empty
  end

  def check_published_with_panopticon(slug, title)
    panopticon_id = panopticon_id_for_slug(slug)

    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(panopticon_id, hash_including(
        slug: slug,
        name: title,
        state: "live",
      ))
  end

  def check_added_to_finder_api(slug, title)
    expect(finder_api).to have_received(:notify_of_publication)
      .with(slug, hash_including(title: title))
  end

  def check_rendered_document_contains_html(document)
    parsed_body = Nokogiri::HTML::Document.parse(document.body)
    expect(parsed_body).to have_css("p")
  end

  def check_rendered_document_contains_header_meta_data(document)
    expect(document.headers.first).to include("text" => "Header")
  end

  def check_for_correctly_archived_editions(document_attrs)
    latest_edition = SpecialistDocumentEdition.where(document_attrs).first
    editions = SpecialistDocumentEdition.where(document_id: latest_edition.document_id)
    previous_editions = editions.to_a - latest_edition.to_a

    expect(latest_edition).to be_published

    previous_editions.each do |edition|
      expect(edition).to be_archived
    end
  end

  def withdraw_document(title)
    go_to_show_page_for_document(title)
    click_button "Withdraw"
  end

  def check_document_is_withdrawn(slug, document_title)
    panopticon_id = panopticon_id_for_slug(slug)

    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(panopticon_id, hash_including(
        name: document_title,
        state: "archived",
      ))

    expect(page).to have_content("withdrawn")
    expect(RenderedSpecialistDocument.where(title: document_title)).to be_empty
    expect(finder_api).to have_received(:notify_of_withdrawal).with(@slug)
  end

  def check_for_documents(*titles)
    titles.each do |title|
      page.should have_content(title)
    end
  end

  def edit_aaib_report(title, updated_fields, publish: false)
    go_to_edit_page_for_aaib_report(title)
    fill_in_fields(updated_fields)

    save_document

    if publish
      save_document
    end
  end

  def edit_document(title, updated_fields, publish: false)
    go_to_edit_page_for_document(title)
    fill_in_fields(updated_fields)

    save_document

    if publish
      publish_document
    end
  end

  def check_for_missing_title_error
    page.should have_content("Title can't be blank")
  end

  def check_for_error(expected_error_message)
    within("ul.errors") do
      expect(page).to have_content(expected_error_message)
    end
  end

  def check_for_new_title(title)
    visit specialist_documents_path
    page.should have_content(title)
  end

  def check_for_new_aaib_report_title(title)
    visit aaib_reports_path
    page.should have_content(title)
  end
end
