module CmaCaseHelpers
  def go_to_edit_page_for_most_recent_case
    warn "DEPRECATED: use #go_to_edit_page_for_document and provide title"
    registry = SpecialistPublisherWiring.get(:specialist_document_repository)
    # TODO: testing antipattern, relies on datastore co-incidence
    document = registry.all.last

    visit edit_specialist_document_path(document.id)
  end

  def make_changes_without_saving(fields)
    go_to_edit_page_for_most_recent_case
    fill_in_fields(fields)
  end

  def generate_preview
    click_button("Preview")
  end

  def check_for_cma_case_body_preview
    expect(current_path).to match(%r{/cma-cases/([0-9a-f-]+|new)})
    within(".preview") do
      expect(page).to have_css("p", text: "Body for preview")
    end
  end

  def check_cma_case_is_published(slug, fields)
    published_cma_case = RenderedSpecialistDocument.find_by_slug(slug)

    expect(published_cma_case.title).to eq(fields.fetch(:title))
    expect(published_cma_case.summary).to eq(fields.fetch(:summary))

    check_metadata_is_rendered(
      published_cma_case,
      fields.except(:title, :summary, :body),
    )

    check_rendered_document_contains_html(published_cma_case)
    check_rendered_document_contains_header_meta_data(published_cma_case)

    check_published_with_panopticon(slug, fields.fetch(:title))
    check_added_to_finder_api(slug, fields.fetch(:title))
  end

  def check_metadata_is_rendered(published_document, fields)
    # TODO: RSpec 3 change to eq(hash_including( ... ))

    fields.each do |key, value|
      expect(published_document.details.fetch(key.to_s)).to eq(value)
    end
  end

  def check_document_is_published_with_legacy_format(slug, fields)
    published_document = RenderedSpecialistDocument.find_by_slug(slug)

    # TODO: RSpec 3 change to eq(hash_including( ... ))
    fields.except(:body).each do |key, value|
      expect(published_document.read_attribute(key)).to eq(value)
    end
  end

  def seed_cases(number_of_cases, state: "draft")
    # TODO: Use the create document service or a more robust way of seeding data
    @created_case_index ||= 0
    number_of_cases.times do
      @created_case_index += 1
      doc = cma_case_builder.call(
        title: "Specialist Document #{@created_case_index}",
        summary: "summary",
        body: "body",
        opened_date: Time.parse("2014-01-01"),
        market_sector: "agriculture-environment-and-natural-resources",
        case_state: "open",
        case_type: "ca98",
        outcome_type: "ca98-commitment",
        state: state,
        document_type: "cma_case",
      )

      PanopticonMapping.create!(
        resource_type: "specialist-document",
        resource_id: doc.id,
        panopticon_id: SecureRandom.hex,
      )

      specialist_document_repository.store(doc)

      # TODO: seeded data is created in the future, this is odd
      Timecop.travel(10.minutes.from_now)
    end
  end
end
