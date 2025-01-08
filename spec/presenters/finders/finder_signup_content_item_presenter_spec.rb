require "spec_helper"

RSpec.describe FinderSignupContentItemPresenter do
  describe "#to_json" do
    Dir["lib/documents/schemas/*.json"].each do |file|
      it "is valid against the #{file} content schemas" do
        read_file = File.read(file)
        payload = JSON.parse(read_file)
        if payload.key?("signup_content_id")
          finder_signup_content_presenter = FinderSignupContentItemPresenter.new(payload, File.mtime(file))
          presented_data = finder_signup_content_presenter.to_json

          expect(presented_data[:schema_name]).to eq("finder_email_signup")
          expect(presented_data).to be_valid_against_publisher_schema("finder_email_signup")
        end
      end
    end
  end

  describe "temporary tests to aid in refactoring schema" do
    Dir["lib/documents/schemas/*.json"].each do |file|
      it "generates temporary output files we can compare against" do
        read_file = File.read(file)
        payload = JSON.parse(read_file)
        if payload.key?("signup_content_id")
          finder_signup_content_presenter = FinderSignupContentItemPresenter.new(payload, File.mtime(file))
          presented_data = finder_signup_content_presenter.to_json

          File.write("spec/presenters/finders/signup_content_items/#{file.split('/').last}", JSON.pretty_generate(presented_data))
        end
      end
    end
  end
end
