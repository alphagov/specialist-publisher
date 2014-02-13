def fill_in_cma_fields(fields)
  fields.slice(:title, :summary, :body).each do |field, text|
    fill_in field.to_s.titlecase, with: text
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

def check_cma_case_does_not_exist_with(attributes)
  refute SpecialistDocumentEdition.exists?(conditions: attributes)
end

def check_for_cma_cases(*titles)
  page.should have_content(Regexp.new(titles.join('.+')))
end

def go_to_edit_page_for_most_recent_case
  artefact = Artefact.where(kind: 'specialist-document').last
  visit edit_specialist_document_path(artefact.id)
end
