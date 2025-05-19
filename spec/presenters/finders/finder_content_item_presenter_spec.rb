require "spec_helper"

RSpec.describe FinderContentItemPresenter do
  describe "#to_json" do
    Dir["lib/documents/schemas/*.json"].each do |file|
      it "is valid against the #{file} content schemas" do
        read_file = File.read(file)
        payload = JSON.parse(read_file)

        presenter = FinderContentItemPresenter.new(
          payload, Time.zone.parse("2016-01-01T00:00:00-00:00")
        )

        expect_any_instance_of(FinderFacetPresenter).to receive(:to_json).and_call_original

        presented_data = presenter.to_json

        expect(presented_data[:schema_name]).to eq("finder")
        expect(presented_data).to be_valid_against_publisher_schema("finder")
      end
    end

    it "should have a summary with content" do
      read_file = File.read("lib/documents/schemas/european_structural_investment_funds.json")
      payload = JSON.parse(read_file)
      payload["summary"] = "anything"

      presenter = FinderContentItemPresenter.new(
        payload, Time.zone.parse("2016-01-01T00:00:00-00:00")
      )

      presented_data = presenter.to_json

      expect(presented_data[:details][:summary].first[:content]).to eq("anything")
    end

    it "should return summary nil with nil content" do
      read_file = File.read("lib/documents/schemas/european_structural_investment_funds.json")
      payload = JSON.parse(read_file)
      payload["summary"] = nil

      presenter = FinderContentItemPresenter.new(
        payload, Time.zone.parse("2016-01-01T00:00:00-00:00")
      )

      presented_data = presenter.to_json

      expect(presented_data[:details][:summary]).to eq(nil)
    end
  end
end
