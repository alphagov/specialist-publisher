def fill_in_cma_fields(fields)
  fields.slice(:title, :summary, :body).each do |field, text|
    fill_in field.to_s.titlecase, with: text
  end
end

def save_document
  click_on "Save as draft"
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
