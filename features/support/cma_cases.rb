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
