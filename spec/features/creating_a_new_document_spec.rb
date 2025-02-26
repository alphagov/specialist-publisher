require "spec_helper"

EXCEPTIONS_TO_GENERAL_TESTING = %w[
  ai_assurance_portfolio_technique
  business_finance_support_scheme
  flood_and_coastal_erosion_risk_management_research_report
  licence_transaction
  research_for_development_output
  statutory_instrument
].freeze

RSpec.feature "Creating a document", type: :feature do
  shared_context "common setup" do |editor, document_type, document_path, new_document_path|
    let(:document) { FactoryBot.create(document_type) }
    let(:content_id) { document["content_id"] }
    let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }
    let(:schema) { document_type.to_s.camelize.constantize.finder_schema }

    before do
      log_in_as_editor(editor)

      allow(SecureRandom).to receive(:uuid).and_return(content_id)
      Timecop.freeze(Time.zone.parse(document["public_updated_at"] || "2015-12-03 16:59:13 UTC"))

      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links

      stub_publishing_api_has_content([document], hash_including(document_type: document_type.to_s))
      stub_publishing_api_has_item(document)
    end

    scenario "getting to the new document page" do
      visit document_path
      click_link "Add another #{schema.document_title}"

      expect(page.status_code).to eq(200)
      expect(page.current_path).to eq(new_document_path)
    end

    scenario "with valid data" do
      visit new_document_path
      fill_in "Title", with: "Example #{document_type.to_s.humanize}"
      fill_in "Summary", with: "Example Summary"
      fill_in "Body", with: "Example Body"

      schema.facets.each do |facet|
        key = facet["key"]
        properties = facet["specialist_publisher_properties"] || {}
        properties["validations"] || {}

        if facet["type"] == "date"
          fill_in "#{document_type}[#{key}(1i)]", with: "2014"
          fill_in "#{document_type}[#{key}(2i)]", with: "01"
          fill_in "#{document_type}[#{key}(3i)]", with: "01"
        elsif properties.key?("select")
          select facet["allowed_values"].first["label"], from: facet["name"], match: :first
        else
          fill_in facet["name"], with: "Example #{facet['name']}"
        end
      end

      case document_type.to_s
      when "marine_equipment_approved_recommendation"
        fill_in "Year adopted", with: "2025"
      when "protected_food_drink_name"
        fill_in "Time of registration (UK scheme)", with: "12:00"
      end

      expect(page).to have_css("div.govspeak-help")
      expect(page).to have_content("To add an attachment, please save the draft first.")
      expect(save_button_disable_with_message).to eq("Saving...")
      click_button "Save as draft"

      expect(page.status_code).to eq(200)
      expect(page).to have_content("Created Example #{document_type.to_s.humanize}")
    end

    scenario "with no data" do
      visit new_document_path
      click_button "Save as draft"

      expect(page.status_code).to eq(422)

      schema.facets.each do |facet|
        facet["key"]
        properties = facet["specialist_publisher_properties"] || {}
        validations = properties["validations"] || {}

        if validations["presence"]
          expect(page).to have_content("#{facet['name']} can't be blank")
        end
      end
    end

    scenario "with invalid content" do
      visit new_document_path

      fill_in "Title", with: "Example #{document_type.to_s.humanize}"
      fill_in "Summary", with: "Example Summary"
      fill_in "Body", with: "<script>alert('hello')</script>"

      click_button "Save as draft"

      expect(page.status_code).to eq(422)
      expect(page).to have_css(".elements-error-summary")
      expect(page).to have_css(".elements-error-message")

      expect(page).to have_content("Body cannot include invalid Govspeak")
    end

    scenario "with invalid date" do
      visit new_document_path

      date_facet = schema.facets.find { |facet| facet["type"] == "date" }

      if date_facet
        key = date_facet["key"]
        fill_in "#{document_type}[#{key}(1i)]", with: "2014"
        fill_in "#{document_type}[#{key}(2i)]", with: ""
        fill_in "#{document_type}[#{key}(3i)]", with: ""

        click_button "Save as draft"

        expect(page.status_code).to eq(422)
        expect(page).to have_css(".elements-error-summary")
        expect(page).to have_css(".elements-error-message")
        expect(page).to have_content("not a valid date")
      end
    end
  end

  Dir["lib/documents/schemas/*.json"].each do |file|
    schema = JSON.parse(File.read(file))
    format = schema["filter"]["format"]

    next if EXCEPTIONS_TO_GENERAL_TESTING.include?(format)

    describe "Creating a #{format.humanize}" do
      base_path = format == "product_safety_alert_report_recall" ? "/product-safety-alerts-reports-recalls" : "/#{format.pluralize.dasherize}"
      include_context "common setup", :gds_editor, format.to_sym, base_path, "#{base_path}/new"
    end
  end
end
