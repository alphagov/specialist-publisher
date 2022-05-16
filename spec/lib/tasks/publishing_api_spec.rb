require "rails_helper"

RSpec.describe "publishing_api rake tasks", type: :task do
  describe "publishing_api:publish_finders" do
    before(:each) do
      Rake::Task["publishing_api:publish_finders"].reenable
      stub_any_publishing_api_put_content
      stub_any_publishing_api_patch_links
      stub_any_publishing_api_publish
    end

    it "publishes all finders to the Publishing API" do
      allow(Rails.application.config).to receive(:publish_pre_production_finders).and_return(true)
      finders = Dir.glob("lib/documents/schemas/*.json")
      content_ids = finders.map do |json_schema|
        MultiJson.load(File.read(json_schema))["content_id"]
      end

      expect { Rake::Task["publishing_api:publish_finders"].invoke }.to output.to_stdout

      content_ids.each do |content_id|
        assert_publishing_api_put_content(content_id)
        assert_publishing_api_patch_links(content_id)
        assert_publishing_api_publish(content_id)
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

  describe "publishing_api:patch_document_type_links" do
    let(:cma_cases) { FactoryBot.create_list(:cma_case, 10) }

    before(:each) do
      Rake::Task["publishing_api:patch_document_type_links"].reenable
      stub_any_publishing_api_patch_links
      stub_publishing_api_has_content(cma_cases, hash_including(document_type: CmaCase.document_type))
    end

    it "patches links for all CMA cases" do
      message = %r{Links patched for #{cma_cases.count} cma_case documents}

      expect {
        Rake::Task["publishing_api:patch_document_type_links"].invoke("cma_case")
      }.to output(message).to_stdout

      cma_cases.each do |cma_case|
        assert_publishing_api_patch_links(cma_case["content_id"])
      end
    end
  end

  describe "publishing_api:publish_finder_and_patch_documents_links" do
    let(:cma_cases) { [FactoryBot.create(:cma_case)] }

    it "publishes a finder and patches document type links by delegating to tasks" do
      expect(Rake::Task["publishing_api:publish_finder"]).to receive(:invoke).with("cma_cases")
      expect(Rake::Task["publishing_api:patch_document_type_links"]).to receive(:invoke).with("cma_case")

      Rake::Task["publishing_api:publish_finder_and_patch_documents_links"].invoke("cma_cases")
    end
  end
end
