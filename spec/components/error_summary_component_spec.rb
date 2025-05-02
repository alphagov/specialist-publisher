require "rails_helper"
require "spec_helper"

RSpec.describe ErrorSummaryComponent, type: :component do
  before do
    @object_with_no_errors = ErrorSummaryTestObject.new("title", Time.zone.today)
    @object_with_errors = ErrorSummaryTestObject.new(nil, nil)
    @object_with_errors.validate
  end

  it "does not render if there are no errors on the object passed in" do
    render_inline(ErrorSummaryComponent.new(object: @object_with_no_errors))
    expect(page.text).to be_empty
  end

  it "constructs a list of links which link to an id based on the objects class and attribute of the error" do
    render_inline(ErrorSummaryComponent.new(object: @object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(page.all(".gem-c-error-summary__list-item").count).to eq 3
    expect(page.all(".gem-c-error-summary__list-item a").count).to eq 3
    expect(first_link.text).to eq "Title can't be blank"
    expect(first_link[:href]).to eq "#error_summary_test_object_title"
    expect(second_link.text).to eq "Date can't be blank"
    expect(second_link[:href]).to eq "#error_summary_test_object_date"
    expect(third_link.text).to eq "Date is invalid"
    expect(third_link[:href]).to eq "#error_summary_test_object_date"
  end

  it "overrides the class in the href with `parent class` if passed in" do
    render_inline(ErrorSummaryComponent.new(object: @object_with_errors, parent_class: "parent_class"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(page.all(".gem-c-error-summary__list-item").count).to eq 3
    expect(page.all(".gem-c-error-summary__list-item a").count).to eq 3
    expect(first_link.text).to eq "Title can't be blank"
    expect(first_link[:href]).to eq "#parent_class_title"
    expect(second_link.text).to eq "Date can't be blank"
    expect(second_link[:href]).to eq "#parent_class_date"
    expect(third_link.text).to eq "Date is invalid"
    expect(third_link[:href]).to eq "#parent_class_date"
  end

  it "constructs data modules for tracking analytics based on the class name and error message" do
    render_inline(ErrorSummaryComponent.new(object: @object_with_errors))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    first_link_data = JSON.parse(first_link["data-ga4-auto"])
    second_link_data = JSON.parse(second_link["data-ga4-auto"])
    third_link_data = JSON.parse(third_link["data-ga4-auto"])

    expect(first_link["data-module"]).to eq "ga4-auto-tracker"
    expect(first_link_data["event_name"]).to eq "form_error"
    expect(first_link_data["type"]).to eq "Editing Error Summary Test Object"
    expect(first_link_data["text"]).to eq "Title can't be blank"
    expect(first_link_data["section"]).to eq "Title"
    expect(first_link_data["action"]).to eq "error"

    expect(second_link["data-module"]).to eq "ga4-auto-tracker"
    expect(second_link_data["event_name"]).to eq "form_error"
    expect(second_link_data["type"]).to eq "Editing Error Summary Test Object"
    expect(second_link_data["text"]).to eq "Date can't be blank"
    expect(second_link_data["section"]).to eq "Date"
    expect(second_link_data["action"]).to eq "error"

    expect(third_link["data-module"]).to eq "ga4-auto-tracker"
    expect(third_link_data["event_name"]).to eq "form_error"
    expect(third_link_data["type"]).to eq "Editing Error Summary Test Object"
    expect(third_link_data["text"]).to eq "Date is invalid"
    expect(third_link_data["section"]).to eq "Date"
    expect(third_link_data["action"]).to eq "error"
  end

  it "when an errors attribute is base it renders the error as text not a link" do
    object = ErrorSummaryTestObject.new("title", Time.zone.today)
    object.errors.add(:base, "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input.")
    render_inline(ErrorSummaryComponent.new(object:))

    expect(page).to have_css(".gem-c-error-summary__list-item a", count: 0)
    expect(page).to have_css(".gem-c-error-summary__list-item span", text: "This is a top level error that is agnostic of model level validations. It has probably been added by an updater service or a controller and does not link to an input.")
  end

  it "renders errors when 'ActiveModel::Errors' are passed in" do
    render_inline(ErrorSummaryComponent.new(object: @object_with_errors.errors, parent_class: "error_summary_test_object"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(page.all(".gem-c-error-summary__list-item").count).to eq 3
    expect(page.all(".gem-c-error-summary__list-item a").count).to eq 3
    expect(first_link.text).to eq "Title can't be blank"
    expect(first_link[:href]).to eq "#error_summary_test_object_title"
    expect(second_link.text).to eq "Date can't be blank"
    expect(second_link[:href]).to eq "#error_summary_test_object_date"
    expect(third_link.text).to eq "Date is invalid"
    expect(third_link[:href]).to eq "#error_summary_test_object_date"
  end

  it "renders errors when an array of 'ActiveModel::Error' objects are passed in" do
    render_inline(ErrorSummaryComponent.new(object: @object_with_errors.errors.errors, parent_class: "error_summary_test_object"))

    first_link = page.all(".gem-c-error-summary__list-item")[0].find("a")
    second_link = page.all(".gem-c-error-summary__list-item")[1].find("a")
    third_link = page.all(".gem-c-error-summary__list-item")[2].find("a")

    expect(page.all(".gem-c-error-summary__list-item").count).to eq 3
    expect(page.all(".gem-c-error-summary__list-item a").count).to eq 3
    expect(first_link.text).to eq "Title can't be blank"
    expect(first_link[:href]).to eq "#error_summary_test_object_title"
    expect(second_link.text).to eq "Date can't be blank"
    expect(second_link[:href]).to eq "#error_summary_test_object_date"
    expect(third_link.text).to eq "Date is invalid"
    expect(third_link[:href]).to eq "#error_summary_test_object_date"
  end
end

class ErrorSummaryTestObject
  include ActiveModel::Model
  attr_accessor :title, :date

  validates :title, :date, presence: true
  validate :date_is_a_date

  def initialize(title, date)
    @title = title
    @date = date
  end

  def date_is_a_date
    errors.add(:date, :invalid) unless date.is_a?(Date)
  end
end
