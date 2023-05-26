require "rails_helper"

RSpec.describe "unpublish rake tasks", type: :task do
  describe "unpublish:redirect_finder" do
    let(:output) { StringIO.new }
    let(:task) { Rake::Task["unpublish:redirect_finder"] }
    before { $stdout = output }
    after { $stdout = STDOUT }

    before(:each) do
      task.reenable
      stub_any_publishing_api_unpublish
    end

    it "returns error message if incorrect finder slug is given" do
      expect { task.invoke("aaib_testing", "https://service.gov.uk") }.to raise_error("Could not find file: lib/documents/schemas/aaib_testing.json")
    end

    it "unpublishes finder with redirect" do
      content_id = MultiJson.load(File.read("lib/documents/schemas/aaib_reports.json"))["content_id"]
      task.invoke("aaib_reports", "https://service.gov.uk")
      expect(output.string).to include("Publishing API response 200")
      expect(output.string).to include("Finder unpublished")
      assert_publishing_api_unpublish(
        content_id,
        type: "redirect",
        alternative_path: "https://service.gov.uk",
        discard_drafts: true,
      )
    end

    it "returns error message if publishing API errors" do
      stub_any_publishing_api_unpublish.and_raise(GdsApi::HTTPServerError.new(500))
      task.invoke("aaib_reports", "https://service.gov.uk")
      expect(output.string).to include("Error unpublishing finder: #<GdsApi::HTTPServerError: GdsApi::HTTPServerError>")
    end
  end
end
