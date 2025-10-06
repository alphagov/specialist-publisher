require "rails_helper"
require "thor"

RSpec.describe "publishing_api rake tasks", type: :task do
  describe "publishing_api:publish_finders" do
    before(:each) do
      Rake::Task["publishing_api:publish_finders"].reenable
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_any_publishing_api_publish
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
    end

    it "publishes all finders to the Publishing API" do
      finders = Dir.glob("lib/documents/schemas/*.json")
      content_ids_with_target_stacks = finders.map do |json_schema|
        { content_id: MultiJson.load(File.read(json_schema))["content_id"], target_stack: MultiJson.load(File.read(json_schema))["target_stack"] }
      end

      expect { Rake::Task["publishing_api:publish_finders"].invoke }.to output.to_stdout

      content_ids_with_target_stacks.each do |item|
        assert_publishing_api_put_content(item[:content_id])
        assert_publishing_api_patch_links(item[:content_id]) if item[:target_stack] == "live"
        assert_publishing_api_publish(item[:content_id]) if item[:target_stack] == "live"
      end
    end

    context "an error triggers the rescue state" do
      it "returns an error message" do
        stub_any_publishing_api_put_content.and_raise(GdsApi::HTTPServerError.new(500))
        error_message = %r{Error publishing finder: #<GdsApi::HTTPServerError: GdsApi::HTTPServerError>}

        expect { Rake::Task["publishing_api:publish_finders"].invoke }.to output(error_message).to_stdout
      end
    end
  end

  describe "publishing_api:publish_finder" do
    before(:each) do
      Rake::Task["publishing_api:publish_finder"].reenable
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_any_publishing_api_publish
      allow_any_instance_of(Thor::Shell::Basic).to receive(:yes?).and_return(true)
    end

    context "incorrect file name is given" do
      it "returns an error message" do
        error_message = %r{#<RuntimeError: Could not find file: lib/documents/schemas/aaib_reportings.json>}

        expect { Rake::Task["publishing_api:publish_finder"].invoke("aaib_reportings") }.to output(error_message).to_stdout
      end
    end

    context "correct file name given" do
      context "no server error present" do
        it "publishes a single finder to the Publishing API" do
          schema = "lib/documents/schemas/aaib_reports.json"
          content_id = MultiJson.load(File.read(schema))["content_id"]

          expect { Rake::Task["publishing_api:publish_finder"].invoke("aaib_reports") }.to output.to_stdout

          assert_publishing_api_put_content(content_id)
          assert_publishing_api_patch_links(content_id)
          assert_publishing_api_publish(content_id)
        end
      end

      context "server error present" do
        it "returns an error message" do
          stub_any_publishing_api_put_content.and_raise(GdsApi::HTTPServerError.new(500))
          error_message = %r{Error publishing finder: #<GdsApi::HTTPServerError: GdsApi::HTTPServerError>}

          expect { Rake::Task["publishing_api:publish_finder"].invoke("aaib_reports") }.to output(error_message).to_stdout
        end
      end
    end
  end
end
