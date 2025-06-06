require "spec_helper"

EXCEPTIONS_TO_GENERAL_TESTING = %w[
  business_finance_support_scheme
  flood_and_coastal_erosion_risk_management_research_report
  licence_transaction
  research_for_development_output
  statutory_instrument
  protected_food_drink_name
].freeze

RSpec.feature "Creating a document", type: :feature do
  shared_context "common setup" do |editor, document_type, document_path, new_document_path|
    let(:document) { FactoryBot.create(document_type) }
    let(:content_id) { document["content_id"] }
    let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }
    let(:schema) { document_type.to_s.camelize.constantize.finder_schema }

    before do
      log_in_as_design_system_editor(editor)

      allow(SecureRandom).to receive(:uuid).and_return(content_id)
      Timecop.freeze(Time.zone.parse(document["public_updated_at"] || "2015-12-03 16:59:13 UTC"))

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      stub_publishing_api_has_content([document], hash_including(document_type: document_type.to_s))
      stub_publishing_api_has_item(document)
    end

    scenario "navigating to the new document page" do
      visit document_path
      click_link "Add another #{schema.document_title}"

      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq(new_document_path)
    end

    scenario "creating a document with valid data" do
      visit new_document_path
      fill_in "Title", with: "Example #{document_type.to_s.humanize}"
      fill_in "Summary", with: "Example Summary"
      fill_in "Body", with: "Example Body"

      schema.facets.each do |facet|
        key = facet["key"]
        properties = facet["specialist_publisher_properties"] || {}

        if facet["type"] == "date"
          fill_in "#{document_type}[#{key}(1i)]", with: "2014"
          fill_in "#{document_type}[#{key}(2i)]", with: "01"
          fill_in "#{document_type}[#{key}(3i)]", with: "01"
        elsif facet["key"] == "year_adopted"
          # This is custom for marine_equipment_approved_recommendation
          fill_in facet["name"], with: "2014"
        elsif properties["select"] == "one"
          select facet["allowed_values"].first["label"], from: facet["name"], match: :first
        elsif properties["select"] == "multiple"
          select facet["allowed_values"].first["label"], from: "#{document_type}[#{facet['key']}][]"
        else
          fill_in facet["name"], with: "Example #{facet['name']}"
        end
      end

      expect(page).to have_css("div.govspeak-help")
      expect(page).to have_content("To add an attachment, please save the draft first.")
      click_button "Save as draft"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Created Example #{document_type.to_s.humanize}")
    end

    scenario "attempting to create a document with no data" do
      visit new_document_path
      fill_in "Body", with: ""
      click_button "Save as draft"

      expect(page.status_code).to eq(422)
      expect(page).to have_css(".govuk-error-summary")
      expect(page).to have_css(".gem-c-error-summary__list-item", text: "Title can't be blank")
      expect(page).to have_css(".gem-c-error-summary__list-item", text: "Summary can't be blank")
      expect(page).to have_css(".gem-c-error-summary__list-item", text: "Body can't be blank")

      expect(page).to have_css(".govuk-error-message", text: "Title can't be blank")
      expect(page).to have_css(".govuk-error-message", text: "Summary can't be blank")
      expect(page).to have_css(".govuk-error-message", text: "Body can't be blank")

      schema.facets.each do |facet|
        properties = facet["specialist_publisher_properties"] || {}
        validations = properties["validations"] || {}

        next unless validations["required"]

        error_regex = /#{facet['key'].humanize} can't be blank|#{facet['name']} can't be blank/
        expect(page).to have_css(".gem-c-error-summary__list-item", text: error_regex)
        expect(page).to have_css(".govuk-error-message", text: error_regex)
      end
    end

    scenario "attempting to create a document with invalid content" do
      visit new_document_path

      fill_in "Title", with: "Example #{document_type.to_s.humanize}"
      fill_in "Summary", with: "Example Summary"
      fill_in "Body", with: "<script>alert('hello')</script>"

      click_button "Save as draft"

      expect(page.status_code).to eq(422)
      expect(page).to have_css(".govuk-error-summary")

      expect(page).to have_css(".govuk-error-message", text: "Body cannot include invalid Govspeak")
    end

    scenario "retaining data when creating a document with some invalid content" do
      visit new_document_path

      fill_in "Title", with: "Example #{document_type.to_s.humanize}"
      fill_in "Summary", with: "Example Summary"
      fill_in "Body", with: "<script>alert('hello')</script>"

      schema.facets.each do |facet|
        key = facet["key"]
        properties = facet["specialist_publisher_properties"] || {}

        if facet["type"] == "date"
          fill_in "#{document_type}[#{key}(1i)]", with: "2014"
          fill_in "#{document_type}[#{key}(2i)]", with: "01"
          fill_in "#{document_type}[#{key}(3i)]", with: "01"
        elsif properties["select"] == "one"
          select facet["allowed_values"].first["label"], from: facet["name"], match: :first
        elsif properties["select"] == "multiple"
          select facet["allowed_values"].first["label"], from: "#{document_type}[#{facet['key']}][]"
        else
          fill_in facet["name"], with: "Example #{facet['name']}"
        end
      end

      click_button "Save as draft"

      expect(page.status_code).to eq(422)
      expect(page).to have_field("#{document_type}[title]", with: "Example #{document_type.to_s.humanize}")
      expect(page).to have_field("#{document_type}[summary]", with: "Example Summary")
      expect(page).to have_field("#{document_type}[body]", with: "<script>alert('hello')</script>")
      expect(page).to have_field("#{document_type}[locale]", with: "en")

      schema.facets.each do |facet|
        key = facet["key"]
        properties = facet["specialist_publisher_properties"] || {}

        if facet["type"] == "date"
          expect(page).to have_field("#{document_type}[#{key}(1i)]", with: "2014")
          expect(page).to have_field("#{document_type}[#{key}(2i)]", with: "01")
          expect(page).to have_field("#{document_type}[#{key}(3i)]", with: "01")
        elsif properties["select"] == "one"
          expect(page).to have_select("#{document_type}[#{key}]", with_selected: facet["allowed_values"].first["label"])
        elsif properties["select"] == "multiple"
          expect(page).to have_select("#{document_type}[#{facet['key']}][]", with_selected: facet["allowed_values"].first["label"])
        else
          expect(page).to have_field("#{document_type}[#{key}]", with: "Example #{facet['name']}")
        end
      end
    end

    scenario "attempting to create a document with an invalid date" do
      visit new_document_path

      date_facet = schema.facets.find { |facet| facet["type"] == "date" }

      if date_facet
        key = date_facet["key"]
        fill_in "#{document_type}[#{key}(1i)]", with: "2014"
        fill_in "#{document_type}[#{key}(2i)]", with: ""
        fill_in "#{document_type}[#{key}(3i)]", with: ""

        click_button "Save as draft"

        expect(page.status_code).to eq(422)
        expect(page).to have_css(".govuk-error-summary")
        expect(page).to have_css(".govuk-error-message")
        expect(page).to have_content("not a valid date")
      end
    end
  end

  Dir["lib/documents/schemas/*.json"].each do |file|
    format = File.basename(file, ".json").singularize

    next if EXCEPTIONS_TO_GENERAL_TESTING.include?(format)

    describe "Creating a #{format.humanize}" do
      base_path = "/#{format.camelize.constantize.admin_slug}"
      include_context "common setup", :gds_editor, format.to_sym, base_path, "#{base_path}/new"
    end
  end
end
