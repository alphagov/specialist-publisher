module CmaCaseHelpers

  def create_cma_case(*args)
    create_document(:cma_case, *args)
  end

  def change_cma_case_without_saving(title, fields)
    go_to_edit_page_for_cma_case(title)
    fill_in_fields(fields)
  end

  def check_for_cma_case_body_preview
    expect(current_path).to match(%r{/cma-cases/([0-9a-f-]+|new)})
    within(".preview") do
      expect(page).to have_css("p", text: "Body for preview")
    end
  end

  def seed_cases(number_of_cases, state: "draft")
    services = SpecialistPublisher.document_services("cma_case")

    docs = number_of_cases.times.map do
      services.create(
        title: "Specialist Document #{SecureRandom.hex}",
        summary: "summary",
        body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
        opened_date: "2014-01-01",
        market_sector: "agriculture-environment-and-natural-resources",
        case_state: "open",
        case_type: "ca98",
        outcome_type: "ca98-commitment",
        document_type: "cma_case",
      ).call
    end

    if state == "published"
      docs.each { |doc| services.publish(doc.id).call }
    end

    docs
  end

  def go_to_cma_case_index
    visit_path_if_elsewhere(cma_cases_path)
  end

  def go_to_show_page_for_cma_case(*args)
    go_to_show_page_for_document(:cma_case, *args)
  end

  def check_cma_case_exists_with(*args)
    check_document_exists_with(:cma_case, *args)
  end

  def go_to_edit_page_for_cma_case(*args)
    go_to_edit_page_for_document(:cma_case, *args)
  end

  def update_title_and_republish_cma_case(current_title, args)
    updated_title = args.fetch(:to)

    edit_cma_case(current_title, { title: updated_title }, minor_update: true, publish: true)
  end

  def withdraw_cma_case(*args)
    withdraw_document(:cma_case, *args)
  end

  def edit_cma_case(title, *args)
    go_to_edit_page_for_cma_case(title)
    edit_document(title, *args)
  end

  def check_for_new_cma_case_title(*args)
    check_for_new_document_title(:cma_case, *args)
  end

  def check_publication_has_not_raised_error
    expect(page).not_to have_content("error")
    expect(current_path).to match(%r{^/cma-cases/[a-f0-9\-]{36}$})
  end

  def check_cma_case_can_be_created
    @document_fields = {
      title: "Example CMA Case",
      summary: "Nullam quis risus eget urna mollis ornare vel eu leo.",
      body: "## Header" + ("\n\nPraesent commodo cursus magna, vel scelerisque nisl consectetur et." * 10),
      opened_date: "2014-01-01",
      market_sector: "Energy",
    }

    create_cma_case(@document_fields)
    check_cma_case_exists_with(@document_fields)
  end

  def check_cma_case_cannot_be_published
    go_to_show_page_for_cma_case(@document_fields.fetch(:title))
    expect(page).not_to have_button("Publish")
  end

  def check_cma_case_cannot_be_withdrawn
    go_to_show_page_for_cma_case(@document_fields.fetch(:title))
    expect(page).not_to have_button("Withdraw")
  end
end
RSpec.configuration.include CmaCaseHelpers, type: :feature
