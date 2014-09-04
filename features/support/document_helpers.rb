module DocumentHelpers
  def create_document(type, fields, save: true, publish: false)
    visit send(:"new_#{type}_path")
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

  def generate_preview
    click_button("Preview")
  end

  def check_document_does_not_exist_with(attributes)
    refute SpecialistDocumentEdition.exists?(conditions: attributes)
  end

  def check_for_unchanged_slug(title, expected_slug)
    go_to_show_page_for_cma_case(title)

    expect(page).to have_link(expected_slug)
  end

  def check_for_published_document_with(attrs)
    expect(
      RenderedSpecialistDocument.where(attrs)
    ).not_to be_empty
  end

  def check_published_with_panopticon(slug, title)
    expect(fake_panopticon).to have_received(:create_artefact!)
      .with(hash_including(
        slug: slug,
        name: title,
        state: "live",
      ))
  end

  def check_document_republished_with_panopticon(slug, title)
    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(
        slug,
        hash_including(
          name: title,
          state: "live",
        ),
      )
  end

  def check_added_to_finder_api(slug, fields)
    expect(finder_api).to have_received(:notify_of_publication)
      .with(slug, hash_including(fields))
  end

  def check_added_to_rummager(slug, fields)
    document_type_slug_prefix_map = {
      "cma-cases" => "cma_case",
      "aaib-reports" => "aaib_report",
      "international-development-funding" => "international_development_fund",
      "drug-safety-update" => "drug_safety_update",
      "drug-device-alerts" => "medical_safety_alert"
    }

    slug_prefix = slug.split("/").first
    document_type = document_type_slug_prefix_map.fetch(slug_prefix)

    rummager_fields = fields
      .except(:summary)
      .merge(
        description: fields.fetch(:summary),
      )

    expect(fake_rummager).to have_received(:add_document)
      .with(document_type, slug, hash_including(rummager_fields))
  end

  def check_rendered_document_contains_html(document)
    parsed_body = Nokogiri::HTML::Document.parse(document.body)
    expect(parsed_body).to have_css("p")
  end

  def check_rendered_document_contains_header_meta_data(document)
    expect(document.details["headers"].first).to include("text" => "Header")
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

  def check_document_is_withdrawn(slug, document_title)
    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(slug, hash_including(
        state: "archived",
      ))

    expect(page).to have_content("withdrawn")
    expect(RenderedSpecialistDocument.where(title: document_title)).to be_empty
    expect(finder_api).to have_received(:notify_of_withdrawal).with(slug)
  end

  def check_for_documents(*titles)
    titles.each do |title|
      page.should have_content(title)
    end
  end

  def check_for_missing_title_error
    page.should have_content("Title can't be blank")
  end

  def check_for_missing_summary_error
    page.should have_content("Summary can't be blank")
  end

  def check_for_invalid_date_error(date_field)
    page.should have_content("#{date_field} should be formatted YYYY-MM-DD")
  end

  def check_for_error(expected_error_message)
    within("ul.errors") do
      expect(page).to have_content(expected_error_message)
    end
  end

  def check_document_is_published(slug, fields)
    check_document_published_to_content_api(slug, fields)
    check_published_with_panopticon(slug, fields.fetch(:title))
    check_added_to_finder_api(slug, fields.except(:body))
    check_added_to_rummager(
      slug,
      fields.except(:body),
    )
  end

  def check_document_published_to_content_api(slug, fields)
    published_document = RenderedSpecialistDocument.find_by_slug(slug)

    expect(published_document.title).to eq(fields.fetch(:title))
    expect(published_document.summary).to eq(fields.fetch(:summary))

    check_metadata_is_rendered(
      published_document,
      fields.except(:title, :summary, :body),
    )

    check_rendered_document_contains_html(published_document)
    check_rendered_document_contains_header_meta_data(published_document)
  end

  def check_document_was_republished(slug, fields)
    check_document_republished_with_panopticon(slug, fields.fetch(:title))
    check_document_published_to_content_api(slug, fields)
    check_added_to_finder_api(slug, fields.except(:body))
    check_added_to_rummager(
      slug,
      fields.except(:body),
    )
  end

  def check_metadata_is_rendered(published_document, fields)
    # TODO: RSpec 3 change to eq(hash_including( ... ))

    fields.each do |key, value|
      expect(published_document.details.fetch(key.to_s)).to eq(value)
    end
  end

  def check_document_exists_with(type, attributes)
    send(:"go_to_show_page_for_#{type}", attributes.fetch(:title))

    attributes.except(:body).each do |_, value|
      expect(page).to have_content(Array(value).join(" "))
    end
  end

  def edit_document(type, title, updated_fields, publish: false)
    send(:"go_to_edit_page_for_#{type}", title)

    fill_in_fields(updated_fields)
    save_document

    if publish
      publish_document
    end
  end

  def go_to_show_page_for_document(type, title)
    raise "Cannot find #{type.to_s.humanize} nil title" if title.nil?
    send(:"go_to_#{type}_index")
    click_link title
  end

  def visit_path_if_elsewhere(path)
    unless current_path == path
      visit(path)
    end
  end

  def check_for_new_document_title(type, title)
    visit send(:"#{type.to_s.pluralize}_path")
    page.should have_content(title)
  end

  def go_to_edit_page_for_document(type, title)
    go_to_show_page_for_document(type, title)

    click_on "Edit"
  end

  def withdraw_document(type, title)
    send(:"go_to_show_page_for_#{type}", title)
    click_button "Withdraw"
  end

  def check_for_javascript_usage_error(field)
    expect(page).to have_content("#{field} cannot include invalid Govspeak, invalid HTML, any JavaScript or images hosted on sites except for")
  end

end
