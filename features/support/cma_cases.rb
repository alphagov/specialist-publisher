# TODO: put these methods in a module or separate object

def create_cma_case(fields, publish: false)
  stub_out_panopticon

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

def check_cma_case_exists_with(attributes)
  assert SpecialistDocumentEdition.exists?(conditions: attributes)
end

def check_for_missing_title_error
  page.should have_content("Title can't be blank")
end

def check_for_new_title
  visit specialist_documents_path
  page.should have_content('Edited Example CMA Case')
end

def check_cma_case_does_not_exist_with(attributes)
  refute SpecialistDocumentEdition.exists?(conditions: attributes)
end

def check_for_cma_cases(*titles)
  page.should have_content(Regexp.new(titles.join('.+')))
end

def check_currently_on_publisher_index_page
  current_path.should eq specialist_documents_path
end

def go_to_edit_page_for_most_recent_case
  registry = SpecialistPublisherWiring.get(:specialist_document_repository)
  document = registry.all.last

  visit edit_specialist_document_path(document.id)
end
