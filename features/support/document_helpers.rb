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

    expected_link = "#{Plek.current.website_root}/#{expected_slug}"
    expect(page).to have_link("View on website", href: expected_link)
  end

  def check_document_published_to_publishing_api(slug, fields, draft: false)
    attributes = {
      title: fields[:title],
      description: fields[:summary],
      format: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "specialist-frontend",
    }
    if draft
      assert_publishing_api_put_draft_item("/#{slug}", attributes)
    else
      assert_publishing_api_put_item("/#{slug}", attributes)
    end
  end

  def check_added_to_rummager(slug, fields)
    document_type_slug_prefix_map = {
      "cma-cases" => "cma_case",
      "aaib-reports" => "aaib_report",
      "asylum-support-decisions" => "asylum_support_decision",
      "international-development-funding" => "international_development_fund",
      "drug-safety-update" => "drug_safety_update",
      "drug-device-alerts" => "medical_safety_alert",
      "european-structural-investment-funds" => "european_structural_investment_fund",
      "maib-reports" => "maib_report",
      "raib-reports" => "raib_report",
      "countryside-stewardship-grants" => "countryside_stewardship_grant",
      "vehicle-recalls-faults" => "vehicle_recalls_and_faults_alert",
    }

    slug_prefix = slug.split("/").first
    document_type = document_type_slug_prefix_map.fetch(slug_prefix)

    rummager_fields = fields
      .except(:summary)
      .merge(
        description: fields.fetch(:summary),
      )

    expect(fake_rummager).to have_received(:add_document)
      .with(document_type, "/#{slug}", hash_including(rummager_fields))
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
    assert_publishing_api_put_item("/#{slug}", format: "gone")

    expect(page).to have_content("withdrawn")
    expect(RenderedSpecialistDocument.where(title: document_title)).to be_empty
  end

  def check_for_documents(*titles)
    titles.each do |title|
      expect(page).to have_content(title)
    end
  end

  def check_for_missing_title_error
    expect(page).to have_content("Title can't be blank")
  end

  def check_for_missing_summary_error
    expect(page).to have_content("Summary can't be blank")
  end

  def check_for_invalid_date_error(date_field)
    expect(page).to have_content("#{date_field} should be formatted YYYY-MM-DD")
  end

  def check_content_preview_link(slug)
    preview_url = "#{Plek.current.find("draft-origin")}/#{slug}"
    expect(page).to have_link("Preview draft", href: preview_url)
  end

  def check_live_link(slug)
    live_url = "#{Plek.current.website_root}/#{slug}"
    expect(page).to have_link("View on website", href: live_url)
  end

  def check_document_is_published(slug, fields)
    check_document_published_to_publishing_api(slug, fields)
    check_added_to_rummager(
      slug,
      fields.except(:body),
    )
  end

  def check_email_alert_api_notified_of_publish
    expect(fake_email_alert_api).to have_received(:send_alert)
      .with(
        hash_including(
          "subject",
          "body",
          "tags",
        )
      )
    reset_email_alert_api_stubs_and_messages
  end

  def check_email_alert_api_is_not_notified_of_publish
    expect(fake_email_alert_api).to_not have_received(:send_alert)
  end

  def check_document_was_republished(slug, fields)
    check_added_to_rummager(
      slug,
      fields.except(:body),
    )
  end

  def check_document_exists_with(type, attributes)
    send(:"go_to_show_page_for_#{type}", attributes.fetch(:title))

    attributes.except(:body).each do |_, value|
      expect(page).to have_content(Array(value).join(" "))
    end
  end

  def edit_document(title, updated_fields, minor_update: false, publish: false)
    fill_in_fields(updated_fields)

    check "Minor update" if minor_update && page.has_field?("Minor update")

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
    expect(page).to have_content(title)
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

  def check_for_slug_clash_warning
    expect(page).to have_content("You can't publish it until you change the title.")
  end

  def check_count_of_logs(expected_count_of_logs)
    count_of_logs = PublicationLog.where(slug: @slug).count
    expect(count_of_logs).to eq(expected_count_of_logs.to_i)
  end

  def check_document_cant_be_published
    expect(page).to_not have_selector(:button, "Publish")
  end

  def document_body
    %{

      ## Header

      Praesent commodo cursus magna, vel scelerisque nisl consectetur et.

      ### Level 2

      Praesent commodo cursus magna, vel scelerisque nisl consectetur et.
    }
  end
end
RSpec.configuration.include DocumentHelpers, type: :feature
