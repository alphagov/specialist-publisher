require "spec_helper"
require "active_record"

class StubBaseRecord
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks
  attr_accessor :some_date, :another_date
end

class StubModel < StubBaseRecord
  include ActiveRecord::AttributeAssignment
  include DateValidation
  validates :some_date, presence: true
  date_attributes :some_date, :another_date
end

RSpec.describe DateValidation do
  it "should be valid when date attribute is a valid date" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 10 })
    expect(model).to be_valid
  end

  it "should be valid when date attribute is a valid date with a time" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 10, 4 => 0, 5 => 0 })
    expect(model).to be_valid
  end

  it "should be invalid when date attribute is an invalid date" do
    date_hashes = [
      { 1 => 2023, 2 => 9, 3 => 40 },
      { 1 => 2023, 2 => -1, 3 => 1 },
    ]
    date_hashes.each do |date_hash|
      model = StubModel.new(some_date: date_hash)
      expect(model).to_not be_valid, "Failed with date hash #{date_hash}"
    end
  end

  it "should be invalid when date attribute is partially completed" do
    date_hashes = [
      { 1 => nil, 2 => 1, 3 => 1 },
      { 1 => 2023, 2 => nil, 3 => 1 },
      { 1 => 2023, 2 => 1, 3 => nil },
    ]
    date_hashes.each do |date_hash|
      model = StubModel.new(some_date: date_hash)
      expect(model).to_not be_valid, "Failed with date hash #{date_hash}"
    end
  end

  it "should be invalid when not all date attribute parts are numeric" do
    date_hashes = [
      { 1 => "Twenty Twenty Three", 2 => 1, 3 => 1 },
      { 1 => 2023, 2 => "January", 3 => 1 },
      { 1 => 2023, 2 => 1, 3 => "One" },
    ]
    date_hashes.each do |date_hash|
      model = StubModel.new(some_date: date_hash)
      expect(model).to_not be_valid, "Failed with date hash #{date_hash}"
    end
  end

  # Rails casts the year part of the date to 0, before passing to the attribute setter, if the original year parameter is a non-numeric string.
  # This is not true for other parts of the date. It caused the validator to accept invalid dates such as the test case below.
  it "should be invalid when year part is not numeric" do
    model = StubModel.new
    params = ActionController::Parameters.new({ stub_model: {
      "some_date(3i)" => "1",
      "some_date(2i)" => "1",
      "some_date(1i)" => "test",
    } })
    model.assign_attributes(params.require(:stub_model).permit(:some_date))
    expect(model).to_not be_valid
  end

  it "should not validate presence if date was invalid" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => "January", 3 => 20 })
    expect(model).to_not be_valid
    expect(model.errors.where(:some_date, :blank)).to be_empty
  end

  it "should not persist validation state between checks" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 1, 3 => nil })
    expect(model).to_not be_valid
    model.some_date = { 1 => 2023, 2 => 1, 3 => 1 }
    expect(model).to be_valid
  end

  it "can validate multiple dates simultaneously" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 1, 3 => nil }, another_date: { 1 => 2023, 2 => 1, 3 => nil })
    expect(model).to_not be_valid
    expect(model.errors.where(:some_date, :invalid_date)).to_not be_empty
    expect(model.errors.where(:another_date, :invalid_date)).to_not be_empty
  end

  it "can handle adding the same attribute twice" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 40 })
    model.some_date = { 1 => 2023, 2 => 9, 3 => 50 }
    expect(model).to_not be_valid
    expect(model.errors.where(:some_date, :invalid_date).count).to eq 1
  end

  it "can validate date attributes multiple times" do
    model = StubModel.new(some_date: { 1 => 2023, 2 => 9, 3 => 40 })
    expect(model).to_not be_valid
  end
end
