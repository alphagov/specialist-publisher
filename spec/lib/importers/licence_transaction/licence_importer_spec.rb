require "spec_helper"
require "gds_api/test_helpers/publishing_api"
require "importers/licence_transaction/licence_importer"

RSpec.describe Importers::LicenceTransaction::LicenceImporter do
  let(:new_content_id) { "0cc89dd8-1055-4e6b-8f64-9a772dbe28db" }
  let(:publishing_api_response) { publishing_api_licences_response }

  before do
    allow(SecureRandom).to receive(:uuid).and_return(new_content_id)

    stub_publishing_api_has_content(
      publishing_api_response,
      { document_type: "licence", page: 1, per_page: 500, states: "published" },
    )
  end

  context "when a licence is valid" do
    before do
      stub_publishing_api_has_links(
        { content_id: "46044b4d-a41b-42c1-882d-8d03e65f24cd", links: publising_api_get_links_response },
      )
    end

    it "migrates the licence" do
      put_content_request = stub_publishing_api_put_content(
        new_content_id, expected_put_content_payload
      )
      publish_request = stub_publishing_api_publish(
        new_content_id, { update_type: "republish", locale: "en" }
      )
      patch_links_request = stub_publishing_api_patch_links(
        new_content_id, { links: expected_patch_links_payload }
      )

      expect { described_class.new.call }
        .to output(successful_import_message).to_stdout

      expect(put_content_request).to have_been_requested
      expect(patch_links_request).to have_been_requested
      expect(publish_request).to have_been_requested
    end
  end

  context "when a licence is invalid" do
    let(:publishing_api_response) do
      publishing_api_licences_response.tap { |licences| licences.first["title"] = nil }
    end

    it "doesn't migrate the licence" do
      expect { described_class.new.call }
        .to output(invalid_licence_error_message).to_stdout

      expect(stub_any_publishing_api_put_content).to_not have_been_requested
      expect(stub_any_publishing_api_patch_links).to_not have_been_requested
      expect(stub_any_publishing_api_publish).to_not have_been_requested
    end
  end

  context "when a licence isn't present in the common licences list" do
    let(:publishing_api_response) do
      publishing_api_licences_response.tap do |licences|
        licences.first["details"]["licence_identifier"] = "1111-2-3"
      end
    end

    it "doesn't migrate the licence" do
      described_class.new.call

      expect(stub_any_publishing_api_put_content).to_not have_been_requested
      expect(stub_any_publishing_api_patch_links).to_not have_been_requested
      expect(stub_any_publishing_api_publish).to_not have_been_requested
    end
  end

  def invalid_licence_error_message
    "[ERROR] licence: /find-licences/art-therapist-registration has validation errors: #<ActiveModel::Errors [#<ActiveModel::Error attribute=title, type=blank, options={}>]>\n"
  end

  def successful_import_message
    "Published: /find-licences/art-therapist-registration\n"
  end

  def expected_put_content_payload
    {
      base_path: "/find-licences/art-therapist-registration",
      title: "Art therapist registration",
      description: "You need to register with the Health and Care Professions Council (HCPC) to practise as an art therapist in the UK",
      document_type: "licence_transaction",
      change_note: "Imported from Publisher",
      schema_name: "specialist_document",
      publishing_app: "specialist-publisher",
      rendering_app: "frontend",
      locale: "en",
      phase: "live",
      details: {
        body: [
          {
            content_type: "text/govspeak",
            content: "$!You must register with the Health and Care Professions Council (HCPC) to practise as an art therapist in the UK.$!\r\n\r\nYou must be registered with HCPC to use any of these job titles:\r\n\r\n* art therapist\r\n* art psychotherapist\r\n* drama therapist\r\n* music therapist\r\n\r\n##Fines and penalties\r\n\r\n%You could be fined up to £5,000 if you call yourself an art therapist, art psychotherapist, drama therapist, or music therapist and you're not registered with the HCPC.%\r\n\r\n*[HCPC]: Health and Care Professions Council",
          },
        ],
        metadata: {
          licence_transaction_continuation_link: "http://www.hpc-uk.org/apply",
          licence_transaction_licence_identifier: "9150-7-1",
          licence_transaction_will_continue_on: "the Health and Care Professions Council (HCPC) website",
        },
        max_cache_time: 10,
        temporary_update_type: false,
        headers: [
          {
            text: "Fines and penalties",
            level: 2,
            id: "fines-and-penalties",
          },
        ],
      },
      routes: [
        {
          path: "/find-licences/art-therapist-registration",
          type: "prefix",
        },
      ],
      redirects: [],
      update_type: "major",
      links: { finder: %w[b8327c0c-a90d-47b6-992b-ea226b4d3306] },
    }
  end

  def expected_patch_links_payload
    {
      organisations: %w[af07d5a5-df63-4ddc-9383-6a666845ebe9],
      primary_publishing_organisation: %w[af07d5a5-df63-4ddc-9383-6a666845ebe9],
      taxons: [],
    }
  end

  def publising_api_get_links_response
    {
      "organisations" => %w[af07d5a5-df63-4ddc-9383-6a666845ebe9],
      "primary_publishing_organisation" => %w[af07d5a5-df63-4ddc-9383-6a666845ebe9],
      "taxons" => [],
    }
  end

  def publishing_api_licences_response
    [
      {
        "auth_bypass_ids" => [],
        "base_path" => "/art-therapist-registration",
        "content_store" => "live",
        "description" => "You need to register with the Health and Care Professions Council (HCPC) to practise as an art therapist in the UK",
        "details" => {
          "licence_overview" => [{
            "content" => "$!You must register with the Health and Care Professions Council (HCPC) to practise as an art therapist in the UK.$!\r\n\r\nYou must be registered with HCPC to use any of these job titles:\r\n\r\n* art therapist\r\n* art psychotherapist\r\n* drama therapist\r\n* music therapist\r\n\r\n##Fines and penalties\r\n\r\n%You could be fined up to £5,000 if you call yourself an art therapist, art psychotherapist, drama therapist, or music therapist and you're not registered with the HCPC.%\r\n\r\n*[HCPC]: Health and Care Professions Council",
            "content_type" => "text/govspeak",
          }],
          "will_continue_on" => "the Health and Care Professions Council (HCPC) website",
          "continuation_link" => "http://www.hpc-uk.org/apply",
          "licence_identifier" => "9150-7-1",
          "external_related_links" => [],
          "licence_short_description" => "Register as an art therapist with the Health and Care Professions Council (HCPC).",
        },
        "document_type" => "licence",
        "first_published_at" => "2012-09-26T17:08:50Z",
        "phase" => "live",
        "public_updated_at" => "2012-10-16T20:23:44Z",
        "published_at" => "2017-08-31T12:27:39Z",
        "publishing_app" => "publisher",
        "publishing_api_first_published_at" => "2016-04-22T10:40:07Z",
        "publishing_api_last_edited_at" => "2017-08-31T12:27:39Z",
        "redirects" => [],
        "rendering_app" => "frontend",
        "routes" => [{ "path" => "/art-therapist-registration", "type" => "prefix" }],
        "schema_name" => "licence",
        "title" => "Art therapist registration",
        "user_facing_version" => 9,
        "update_type" => "republish",
        "publication_state" => "published",
        "content_id" => "46044b4d-a41b-42c1-882d-8d03e65f24cd",
        "locale" => "en",
        "lock_version" => 10,
        "updated_at" => "2017-08-31T12:27:39Z",
        "state_history" => { "4" => "superseded", "7" => "superseded", "1" => "superseded", "3" => "superseded", "9" => "published", "5" => "superseded", "2" => "superseded", "8" => "superseded", "6" => "superseded" },
        "links" => {},
      },
    ]
  end
end
