module CmaCaseHelpers
  def create_cma_case(fields, publish: false)
    stub_out_panopticon
    stub_finder_api

    visit new_specialist_document_path
    fill_in_cma_fields(fields)

    if publish
      publish_document
    else
      save_document
    end
  end

  def edit_cma_case(fields, publish: false)
    go_to_edit_page_for_most_recent_case
    fill_in_cma_fields(fields)

    if publish
      publish_document
    else
      save_document
    end
  end

  def fill_in_cma_fields(fields)
    fields.slice(:title, :summary, :body, :opened_date).each do |field, text|
      fill_in field.to_s.humanize, with: text
    end
  end

  def save_document
    click_on "Save as draft"
  end

  def publish_document
    click_on "Save and publish"
  end

  def check_slug_registered_with_panopticon(slug)
    expect(fake_panopticon).to have_received(:create_artefact!)
      .with(hash_including(slug: slug))
  end

  def check_cma_case_exists_with(attributes)
    expect(
      # LOL: Mongiod helpfully replaces "\n" with "\r\n" so a body
      #      containing line breaks will never match.
      #      Perhaps we should just match on slug?
      SpecialistDocumentEdition.exists?(conditions: attributes.except(:body))
    ).to be(true)
  end

  def check_for_missing_title_error
    page.should have_content("Title can't be blank")
  end

  def check_for_error(expected_error_message)
    within("ul.errors") do
      expect(page).to have_content(expected_error_message)
    end
  end

  def check_for_new_title
    visit specialist_documents_path
    page.should have_content('Edited Example CMA Case')
  end

  def check_cma_case_does_not_exist_with(attributes)
    refute SpecialistDocumentEdition.exists?(conditions: attributes)
  end

  def check_for_cma_cases(*titles)
    # TODO: will give terrible message, check for each individually
    page.should have_content(Regexp.new(titles.join('.+')))
  end

  def check_currently_on_publisher_index_page
    current_path.should eq(specialist_documents_path)
  end

  def go_to_edit_page_for_most_recent_case
    warn "DEPRECATED: use #go_to_edit_page_for_document and provide title"
    registry = SpecialistPublisherWiring.get(:specialist_document_repository)
    # TODO: testing antipattern, relies on datastore co-incidence
    document = registry.all.last

    visit edit_specialist_document_path(document.id)
  end

  def go_to_document_index
    unless current_path == specialist_documents_path
      visit(specialist_documents_path)
    end
  end

  def go_to_show_page_for_document(document_title)
    go_to_document_index

    click_link document_title
  end

  def go_to_edit_page_for_document(document_title)
    go_to_document_index

    document_listing = page.find("ul.document-list li", text: document_title)
    edit_link = document_listing.find("a", text: "edit")
    edit_link.click
  end

  def make_changes_without_saving(fields)
    go_to_edit_page_for_most_recent_case
    fill_in_cma_fields(fields)
  end

  def generate_preview
    click_button("Preview")
  end

  def check_for_cma_case_body_preview
    expect(current_path).to match(%r{/specialist-documents/[0-9a-f-]+})
    within('.preview') do
      expect(page).to have_css('p', text: 'Body for preview')
    end
  end

  def update_title_and_republish(args)
    updated_title = args.fetch(:to)

    go_to_edit_page_for_most_recent_case

    fill_in_cma_fields(
      title: updated_title,
    )

    publish_document
  end

  def check_for_unchanged_slug(expected_slug)
    go_to_edit_page_for_most_recent_case

    expect(page).to have_css(".slug span", text: expected_slug)
  end

  def capture_most_recent_slug
    current_path_to_return_to = current_path

    go_to_edit_page_for_most_recent_case

    capture_slug.tap {
      visit(current_path_to_return_to)
    }
  end

  def capture_slug
    page.all(".slug span").last.text
  end

  def check_cma_case_is_published(title)
    published_cma_case = RenderedSpecialistDocument.where(title: title).first

    expect(published_cma_case).not_to be_nil

    check_rendered_document_contains_html(published_cma_case)
    check_rendered_document_contains_header_meta_data(published_cma_case)

    check_published_with_panopticon(title)
    check_added_to_finder_api(title)
  end

  def check_published_with_panopticon(title)
    # TODO: properly test that the received panopticon id is correct
    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(anything, hash_including(name: title, state: "live"))
  end

  def check_added_to_finder_api(title)
    # TODO: properly test that the received panopticon id is correct
    expect(finder_api).to have_received(:notify_of_publication)
      .with(anything, hash_including(title: title))
  end

  def check_rendered_document_contains_html(document)
    parsed_body = Nokogiri::HTML::Document.parse(document.body)
    expect(parsed_body).to have_css("p")
  end

  def check_rendered_document_contains_header_meta_data(document)
    expect(document.headers.first).to include( "text" => "Header" )
  end

  def seed_cases(number_of_cases, state: 'draft')
    # TODO: Use the create document service or a more robust way of seeding data
    @created_case_index ||= 0
    number_of_cases.times do
      @created_case_index += 1
      doc = specialist_document_builder.call(
        title: "Specialist Document #{@created_case_index}",
        summary: "summary",
        body: "body",
        opened_date: Time.zone.parse("2014-01-01"),
        market_sector: 'agriculture-environment-and-natural-resources',
        case_state: 'open',
        case_type: 'ca98',
        outcome_type: 'ca98-commitment',
        state: state,
      )

      PanopticonMapping.create!(
        document_id: doc.id,
        panopticon_id: SecureRandom.hex,
      )

      specialist_document_repository.store!(doc)

      # TODO: seeded data is created in the future, this is odd
      Timecop.travel(10.minutes.from_now)
    end
  end

  def withdraw_document(title)
    visit specialist_documents_path
    click_link title
    click_button 'Withdraw'
  end

  def check_document_is_withdrawn(document_title)
    # TODO: properly test that the received panopticon id is correct
    expect(fake_panopticon).to have_received(:put_artefact!)
      .with(anything, hash_including(
        name: document_title,
        state: "archived",
      ))

    expect(page).to have_content("Publication state: withdrawn")
    expect(RenderedSpecialistDocument.where(title: document_title)).to be_empty
    expect(finder_api).to have_received(:notify_of_withdrawal).with(@slug)
  end
end
