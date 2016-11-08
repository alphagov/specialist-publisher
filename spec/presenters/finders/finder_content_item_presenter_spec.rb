require 'spec_helper'
require_relative "../../../app/presenters/finders/finder_content_item_presenter"

RSpec.describe FinderContentItemPresenter do
  describe "#to_json" do
    Dir["lib/documents/schemas/*.yml"].each do |file|
      it "is valid against the #{file} content schemas" do
        payload = YAML.load_file(file)

        presenter = FinderContentItemPresenter.new(
          payload, "2016-01-01T00:00:00-00:00"
        )

        presented_data = presenter.to_json

        expect(presented_data[:schema_name]).to eq("finder")
        expect(presented_data).to be_valid_against_schema("finder")
      end
    end
  end
end
