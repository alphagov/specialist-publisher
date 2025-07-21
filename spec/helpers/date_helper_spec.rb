require "rails_helper"

RSpec.describe DateHelper, type: :helper do
  describe "date_param_value" do
    it "creates a hyphen delimited date string from params" do
      params = { "my_date(1i)" => "2016", "my_date(2i)" => "02", "my_date(3i)" => "01" }
      expect(date_param_value(params, "my_date")).to eq("2016-02-01")
    end

    it "is indifferent about param access" do
      params = { :"my_date(1i)" => "2016", :"my_date(2i)" => "02", "my_date(3i)" => "01" }
      expect(date_param_value(params, "my_date")).to eq("2016-02-01")
    end

    it "zero pads date values" do
      params = { "my_date(1i)" => "2016", "my_date(2i)" => "2", "my_date(3i)" => "01" }
      expect(date_param_value(params, "my_date")).to eq("2016-02-01")
    end

    it "doesn't alter non-numerical values" do
      params = { "my_date(1i)" => "some", "my_date(2i)" => "bad", "my_date(3i)" => "data" }
      expect(date_param_value(params, "my_date")).to eq("some-bad-data")
    end

    it "doesn't concatenate empty values" do
      params = { "my_date(1i)" => "", "my_date(2i)" => "", "my_date(3i)" => "" }
      expect(date_param_value(params, "my_date")).to eq("")
    end
  end

  describe "clean_key" do
    it "strips Rails-like multiple parameter suffixes" do
      expect(clean_key("my_date(1i)")).to eq("my_date")
    end

    it "doesn't alter keys without suffixes" do
      expect(clean_key("my_date")).to eq("my_date")
    end
  end
end
