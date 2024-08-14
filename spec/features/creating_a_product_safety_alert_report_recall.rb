require "spec_helper"

RSpec.feature "Creating a product safety alert recall", type: :feature do
  let(:product_safety_alert_recall) { FactoryBot.create(:product_safety_alert_report_recall) }
  let(:content_id) { product_safety_alert_recall["content_id"] }
  let(:save_button_disable_with_message) { page.find_button("Save as draft")["data-disable-with"] }

  before do
    log_in_as_editor(:product_safety_alert_editor)
    allow(SecureRandom).to receive(:uuid).and_return(content_id)

    stub_publishing_api_has_content([product_safety_alert_recall], hash_including(document_type: SpecialistDocument::ProductSafetyAlertReportRecall.document_type))
    stub_publishing_api_has_item(product_safety_alert_recall)
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  scenario "visiting the new recall page" do
    visit "/product-safety-alerts-reports-recalls"
    click_link "Add another Product Safety Alerts, Reports and Recalls"
    expect(page.status_code).to eq(200)
    expect(page.current_path).to eq("/product-safety-alerts-reports-recalls/new")
  end

  scenario "creating the new product safety alert recall with no data" do
    visit "/product-safety-alerts-reports-recalls/new"

    click_button "Save as draft"

    expect(page.status_code).to eq(422)

    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Title can't be blank")
    expect(page).to have_content("Summary can't be blank")
    expect(page).to have_content("Body can't be blank")
    expect(page).to have_content("Product measure type can't be blank")
  end

  scenario "creating the new product safety recall with valid data" do
    visit "/product-safety-alerts-reports-recalls/new"

    fill_in "Title", with: "Example product safety recall"
    fill_in "Summary", with: "This is the summary of an example product safety recall"
    fill_in "Body", with: "## Header#{"\n\nThis is the long body of an example product safety recall" * 2}"
    select "Product recall", from: "Alert type"
    select "Serious", from: "Risk level"
    select "Chemical products", from: "Product category"
    select "Destruction of the product", from: "Measure type"
    fill_in "[product_safety_alert_report_recall]product_recall_alert_date(1i)", with: "2022"
    fill_in "[product_safety_alert_report_recall]product_recall_alert_date(2i)", with: "02"
    fill_in "[product_safety_alert_report_recall]product_recall_alert_date(3i)", with: "02"

    expect(page).to have_css("div.govspeak-help")
    expect(page).to have_content("To add an attachment, please save the draft first.")
    expect(save_button_disable_with_message).to eq("Saving...")

    click_button "Save as draft"

    expected_sent_payload = {
      "base_path" => "/product-safety-alerts-reports-recalls/example-product-safety-recall",
      "title" => "Example product safety recall",
      "description" => "This is the summary of an example product safety recall",
      "document_type" => "product_safety_alert_report_recall",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "government-frontend",
      "locale" => "en",
      "phase" => "live",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header\r\n\r\nThis is the long body of an example product safety recall\r\n\r\nThis is the long body of an example product safety recall",
          },
        ],
        "metadata" => {
          "product_alert_type" => "product-recall",
          "product_risk_level" => "serious",
          "product_category" => "chemical-products",
          "product_measure_type" => %w[destruction-of-the-product],
          "product_recall_alert_date" => "2022-02-02",
        },
        "max_cache_time" => 10,
        "headers" => [
          { "text" => "Header", "level" => 2, "id" => "header" },
        ],
        "temporary_update_type" => false,
      },
      "routes" => [{ "path" => "/product-safety-alerts-reports-recalls/example-product-safety-recall", "type" => "exact" }],
      "redirects" => [],
      "update_type" => "major",
      "links" => {
        "finder" => %w[a22b3f1f-2c91-49a1-a469-ff21d465c543],
      },
    }

    assert_publishing_api_put_content(content_id, expected_sent_payload)

    expect(page.status_code).to eq(200)
    expect(page).to have_content("Created Example product safety recall")
    expect(page).to have_content("Bulk published false")
  end
end
