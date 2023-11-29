require "rails_helper"

RSpec.describe "unpublish rake tasks", type: :task do
  describe "unpublish:redirect_finder" do
    let(:test_output) { StringIO.new }
    let(:task) { Rake::Task["unpublish:redirect_finder"] }
    before { $stdout = test_output }
    after { $stdout = STDOUT }

    before(:each) do
      task.reenable
      stub_any_publishing_api_unpublish
    end

    it "returns error message if incorrect finder slug is given" do
      error_message = %r{#<RuntimeError: Could not find any schema with slug: aaib-testing>}
      expect { task.invoke("aaib-testing", "https://service.gov.uk") }.to output(error_message).to_stdout
    end

    it "unpublishes finder with redirect" do
      content_id = MultiJson.load(File.read("lib/documents/schemas/aaib_reports.json"))["content_id"]
      task.invoke("aaib-reports", "https://service.gov.uk")
      expect(test_output.string).to include("Publishing API response 200")
      expect(test_output.string).to include("Finder unpublished")
      assert_publishing_api_unpublish(
        content_id,
        type: "redirect",
        alternative_path: "https://service.gov.uk",
        discard_drafts: true,
      )
    end

    it "returns error message if publishing API errors" do
      stub_any_publishing_api_unpublish.and_raise(GdsApi::HTTPServerError.new(500))
      error_message = %r{Error unpublishing finder: #<GdsApi::HTTPServerError: GdsApi::HTTPServerError>}
      expect { task.invoke("aaib-reports", "https://service.gov.uk") }.to output(error_message).to_stdout
    end
  end
end
