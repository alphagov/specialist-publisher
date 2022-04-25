require "rails_helper"

RSpec.describe "rake publishing_api:publish_finders", type: :task do
  before(:each) do
    Rake::Task["publishing_api:publish_finders"].reenable
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_any_publishing_api_publish
  end

  after(:each) do
    Rake::Task["publishing_api:publish_finders"].reenable
  end

  it "publishes all finders to the Publishing API" do
    Rails.application.config.publish_pre_production_finders = true
    finders = Dir.glob("lib/documents/schemas/*.json")
    content_ids = finders.map do |json_schema|
      MultiJson.load(File.read(json_schema))["content_id"]
    end

    Rake::Task["publishing_api:publish_finders"].invoke

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

RSpec.describe "rake publishing_api:publish_finder", type: :task do
  before(:each) do
    Rake::Task["publishing_api:publish_finder"].reenable
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_any_publishing_api_publish
  end

  after(:each) do
    Rake::Task["publishing_api:publish_finder"].reenable
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
        content_id = "b7574bba-969f-4c49-855a-ae1586258ff6"

        Rake::Task["publishing_api:publish_finder"].invoke("aaib_reports")

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

RSpec.describe "rake publishing_api:patch_document_type_links", type: :task do
  let(:cma_cases) do
    ten_example_cases = 10.times.collect do
      FactoryBot.create(:cma_case)
    end
    ten_example_cases
  end

  before(:each) do
    Rake::Task["publishing_api:patch_document_type_links"].reenable
    stub_any_publishing_api_patch_links
    stub_publishing_api_has_content(cma_cases, hash_including(document_type: CmaCase.document_type))
  end

  after(:each) do
    Rake::Task["publishing_api:patch_document_type_links"].reenable
  end

  it "patches links for all CMA cases" do
    message = %r{Links patched for 10 cma_case documents}

    expect {
      Rake::Task["publishing_api:patch_document_type_links"].invoke("cma_case")
    }.to output(message).to_stdout
  end
end

RSpec.describe "rake publishing_api:publish_finder_and_patch_documents_links", type: :task do
  let(:cma_cases) { [FactoryBot.create(:cma_case)] }

  before(:each) do
    Rake::Task["publishing_api:publish_finder_and_patch_documents_links"].reenable
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_any_publishing_api_publish
    stub_publishing_api_has_content(cma_cases, hash_including(document_type: CmaCase.document_type))
  end

  after(:each) do
    Rake::Task["publishing_api:publish_finder_and_patch_documents_links"].reenable
  end

  it "publishes a CMA case to the Publishing API and patches links for all its documents" do
    message = %r{Links patched for 1 cma_case documents}
    content_id = "fef4ac7c-024a-4943-9f19-e85a8369a1f3"

    expect {
      Rake::Task["publishing_api:publish_finder_and_patch_documents_links"].invoke("cma_cases")
    }.to output(message).to_stdout

    assert_publishing_api_put_content(content_id)
    assert_publishing_api_patch_links(content_id)
    assert_publishing_api_publish(content_id)
  end
end
