require "rails_helper"

RSpec.describe FacetInputComponent::DateComponent, type: :component do
  it "should render date field for new date field" do
    document = CmaCase.new

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", {}))

    expect(page.find_field("cma_case[opened_date(1i)]").value).to be_nil
    expect(page.find_field("cma_case[opened_date(2i)]").value).to be_nil
    expect(page.find_field("cma_case[opened_date(3i)]").value).to be_nil
  end

  it "should render date field for existing date on document" do
    content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
    document = DocumentBuilder.build(CmaCase, content_item)
    document.opened_date = "2025-01-02"

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", {}))

    expect(page).to have_field("cma_case[opened_date(1i)]", with: "2025")
    expect(page).to have_field("cma_case[opened_date(2i)]", with: "1")
    expect(page).to have_field("cma_case[opened_date(3i)]", with: "2")
  end

  it "should render date field for existing date in params" do
    document = CmaCase.new
    params = {
      "cma_case" => {
        "opened_date(1i)" => "2025",
        "opened_date(2i)" => "1",
        "opened_date(3i)" => "2",
      },
    }

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", params))

    expect(page).to have_field("cma_case[opened_date(1i)]", with: "2025")
    expect(page).to have_field("cma_case[opened_date(2i)]", with: "1")
    expect(page).to have_field("cma_case[opened_date(3i)]", with: "2")
  end

  it "should render date field for partially filled date from params" do
    content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
    document = DocumentBuilder.build(CmaCase, content_item)
    params = {
      "cma_case" => {
        "opened_date(1i)" => "2025",
        "opened_date(2i)" => "",
        "opened_date(3i)" => "",
      },
    }

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", params))

    expect(page).to have_field("cma_case[opened_date(1i)]", with: "2025")
    expect(page).to have_field("cma_case[opened_date(2i)]", with: "")
    expect(page).to have_field("cma_case[opened_date(3i)]", with: "")
  end

  it "should render date field for invalid partially filled date from params" do
    content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
    document = DocumentBuilder.build(CmaCase, content_item)
    params = {
      "cma_case" => {
        "opened_date(1i)" => "not",
        "opened_date(2i)" => "",
        "opened_date(3i)" => "",
      },
    }

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", params))

    expect(page).to have_field("cma_case[opened_date(1i)]", with: "not")
    expect(page).to have_field("cma_case[opened_date(2i)]", with: "")
    expect(page).to have_field("cma_case[opened_date(3i)]", with: "")
  end

  it "should render date field for invalid filled date in params" do
    content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
    document = DocumentBuilder.build(CmaCase, content_item)
    params = {
      "cma_case" => {
        "opened_date(1i)" => "not",
        "opened_date(2i)" => "a",
        "opened_date(3i)" => "date",
      },
    }

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", params))

    expect(page).to have_field("cma_case[opened_date(1i)]", with: "not")
    expect(page).to have_field("cma_case[opened_date(2i)]", with: "a")
    expect(page).to have_field("cma_case[opened_date(3i)]", with: "date")
  end

  it "should allow params to overwrite document model with empty values in cases of clearing out value on the form" do
    content_item = FactoryBot.create(:cma_case, :draft, title: "Example CMA Case")
    document = DocumentBuilder.build(CmaCase, content_item)
    document.opened_date = "2025-01-02"
    params = {
      "cma_case" => {
        "opened_date(1i)" => "",
        "opened_date(2i)" => "",
        "opened_date(3i)" => "",
      },
    }

    render_inline(described_class.new(document, "cma_case", :opened_date, "Opened Date", params))

    expect(page).to have_field("cma_case[opened_date(1i)]", with: "")
    expect(page).to have_field("cma_case[opened_date(2i)]", with: "")
    expect(page).to have_field("cma_case[opened_date(3i)]", with: "")
  end

  it "should render error message error on document" do
    content_item = FactoryBot.create(:trademark_decision, :draft, title: "Example")
    document = DocumentBuilder.build(TrademarkDecision, content_item)
    document.trademark_decision_date = nil
    document.valid?

    render_inline(described_class.new(document, "cma_case", :trademark_decision_date, "Decision Date", {}))

    expect(page).to have_css(".govuk-error-message")
  end
end
