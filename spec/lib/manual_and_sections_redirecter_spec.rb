require "spec_helper"
require "gds_api/test_helpers/publishing_api_v2"
require "manual_and_sections_redirecter"

RSpec.describe ManualAndSectionsRedirecter, :redirect do
  include GdsApi::TestHelpers::PublishingApiV2

  def redirect_body(base_path, destination)
    {
      "format" => "redirect",
      "publishing_app" => "specialist-publisher",
      "update_type" => "major",
      "base_path" => base_path,
      "redirects" => [
        {
          "path" => base_path,
          "type" => "exact",
          "destination" => destination
        }
      ]
    }
  end

  let(:section_1_content_id) { SecureRandom.uuid }
  let(:section_2_content_id) { SecureRandom.uuid }
  let(:section_3_content_id) { SecureRandom.uuid }

  let(:links) do
    {
      "sections" => [
        {
          "base_path" => "/foo/part-1",
          "content_id" => section_1_content_id
         },
        {
          "base_path" => "/foo/part-2",
          "content_id" => section_2_content_id
        },
        {
          "base_path" => "/foo/part-3",
          "content_id" => section_3_content_id
        },
      ]
    }
  end

  let(:publishing_api) { SpecialistPublisher.services(:publishing_api) }
  let(:destination) { "/bar" }
  let(:logger) { double(:logger) }
  let(:manual_content_id) { SecureRandom.uuid }
  let(:publishing_api_endpoint) { GdsApi::TestHelpers::PublishingApiV2::PUBLISHING_API_V2_ENDPOINT }

  before do
    allow(logger).to receive(:puts)

    stub_request(:get, "#{publishing_api_endpoint}/content?document_type=manual&fields%5B%5D=base_path&fields%5B%5D=content_id&publishing_app=specialist-publisher").to_return(
      status: 200, body: {
        "results" => [
          { "content_id" => manual_content_id, "base_path" => "/foo" },
          { "content_id" => SecureRandom.uuid, "base_path" => "/bar" },
          { "content_id" => SecureRandom.uuid, "base_path" => "/baz" },
          { "content_id" => SecureRandom.uuid, "base_path" => "/meh" },
        ]
      }.to_json
    )
    stub_request(:get, "#{publishing_api_endpoint}/linked/#{manual_content_id}?fields%5B%5D=base_path&fields%5B%5D=content_id&link_type=manual").to_return(
      status: 200, body: links["sections"].to_json
    )

    publishing_api_has_item("content_id" => manual_content_id, "base_path" => "/foo", "links" => links)

    stub_publishing_api_put_content(manual_content_id, redirect_body("/foo", destination))
    stub_publishing_api_put_content(manual_content_id, redirect_body("/foo/updates", destination))
    stub_publishing_api_publish(manual_content_id, "update_type" => "major")

    stub_publishing_api_put_content(section_1_content_id, redirect_body("/foo/part-1", destination))
    stub_publishing_api_publish(section_1_content_id, "update_type" => "major")

    stub_publishing_api_put_content(section_2_content_id, redirect_body("/foo/part-2", destination))
    stub_publishing_api_publish(section_2_content_id, "update_type" => "major")

    stub_publishing_api_put_content(section_3_content_id, redirect_body("/foo/part-3", destination))
    stub_publishing_api_publish(section_3_content_id, "update_type" => "major")

    described_class.new(logger: logger, base_path: "/foo", destination: "/bar").redirect
  end

  it "publishes a redirect for the manual and redirects for each section" do
    assert_publishing_api_put_content(manual_content_id, redirect_body("/foo", destination))
  end

  it "publishes a redirect for each of the manual sections" do
    assert_publishing_api_put_content(section_1_content_id, redirect_body("/foo/part-1", destination))
    assert_publishing_api_put_content(section_2_content_id, redirect_body("/foo/part-2", destination))
    assert_publishing_api_put_content(section_3_content_id, redirect_body("/foo/part-3", destination))
  end
end
