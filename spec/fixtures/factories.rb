FactoryGirl.define do
  factory :user do
    sequence(:uid) { |n| "uid-#{n}" }
    sequence(:name) { |n| "Joe Bloggs #{n}" }
    sequence(:email) { |n| "joe#{n}@bloggs.com" }
    if defined?(GDS::SSO::Config)
      # Grant permission to signin to the app using the gem
      permissions { ["signin"] }
    end
  end

  factory :editor, parent: :user do
    permissions %w(signin editor)
  end

  factory :gds_editor, parent: :user do
    organisation_slug "government-digital-service"
    organisation_content_id "af07d5a5-df63-4ddc-9383-6a666845ebe9"
    permissions %w(signin gds_editor)
  end

  factory :cma_editor, parent: :editor do
    organisation_slug "competition-and-markets-authority"
    organisation_content_id "957eb4ec-089b-4f71-ba2a-dc69ac8919ea"
  end

  factory :writer, aliases: [:cma_writer], parent: :editor do
    organisation_slug "competition-and-markets-authority"
    organisation_content_id "957eb4ec-089b-4f71-ba2a-dc69ac8919ea"
    permissions %w(signin)
  end

  factory :aaib_editor, parent: :editor do
    organisation_slug "air-accidents-investigation-branch"
    organisation_content_id "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4"
  end

  factory :dfid_editor, parent: :editor do
    organisation_slug "department-for-international-development"
    organisation_content_id "db994552-7644-404d-a770-a2fe659c661f"
  end

  sequence :content_id do |_|
    SecureRandom.uuid
  end

  factory :document, class: Hash do
    content_id
    base_path "/a/b"
    title "Example document"
    description "This is the summary of example document"
    schema_name "specialist_document"
    publishing_app "specialist-publisher"
    rendering_app "specialist-frontend"
    locale "en"
    phase "live"
    redirects []
    update_type "major"
    public_updated_at "2015-11-16T11:53:30"
    updated_at "2015-11-15T11:53:30"
    publication_state "draft"
    routes {
      [
        {
          "path" => base_path,
          "type" => "exact",
        }
      ]
    }

    details { default_details }

    transient do
      default_details {
        {
          "body" => [
            {
              "content_type" => "text/govspeak",
              "content" => "## Header" + ("\r\n\r\nThis is the long body of an example document" * 10)
            },
            {
              "content_type" => "text/html",
              "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example document</p>\n" * 10)
            }
          ],
          "headers" => [{
            "text" => "Header",
            "level" => 2,
            "id" => "header",
          }],
          "metadata" => default_metadata,
          "max_cache_time" => 10,
          "change_history" => [],
        }
      }
      default_metadata { {} }
    end

    initialize_with {
      merged_details = default_details.deep_stringify_keys.deep_merge(details.deep_stringify_keys)
      attributes.merge(details: merged_details)
    }
    to_create(&:deep_stringify_keys!)
  end
end
