Given(/^some published and draft specialist documents exist$/) do
  seed_cases(1, state: "draft")
  seed_cases(2, state: "published")
end

Given(/^their RenderedSpecialistDocument records are missing$/) do
  destroy_all_rendered_specialist_document_records
end

When(/^I run the "(.*?)" script$/) do |script_path|
  %x{#{Rails.root.join(script_path)}}
  status = $?
  unless status.success?
    raise "Execution of #{script_path} failed (exit status #{status.exitstatus}) with '#{output}'"
  end
end

Then(/^the RenderedSpecialistDocument records of published documents should be regenerated$/) do
  check_all_published_documents_have_valid_rendered_specialist_documents
end
