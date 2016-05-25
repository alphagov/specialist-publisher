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
    public_updated_at "2015-11-16T11:53:30+00:00"
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

  factory :aaib_report, parent: :document do
    base_path "/aaib-reports/example-aaib-report"
    document_type "aaib_report"

    transient do
      default_metadata {
        {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "aaib_report",
        }
      }
    end
  end

  factory :cma_case, parent: :document do
    base_path "/cma-cases/example-cma-case"
    document_type "cma_case"

    transient do
      default_metadata {
        {
          "document_type" => "cma_case",
          "opened_date" => "2014-01-01",
          "closed_date" => "2015-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "closed",
          "market_sector" => ["energy"],
          "outcome_type" => "ca98-no-grounds-for-action-non-infringement",
        }
      }
    end
  end

  factory :countryside_stewardship_grant, parent: :document do
    base_path "/countryside-stewardship-grants/example-countryside-stewardship-grant"
    document_type "countryside_stewardship_grant"

    transient do
      default_metadata {
        {
          "document_type" => "countryside_stewardship_grant",
        }
      }
    end
  end

  factory :dfid_research_output, parent: :document do
    base_path "/dfid-research-outputs/example-dfid-research-output"
    document_type "dfid_research_output"

    transient do
      default_metadata {
        {
          "country" => "GB",
          "document_type" => "dfid_research_output",
        }
      }
    end
  end

  factory :employment_appeal_tribunal_decision, parent: :document do
    base_path "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision"
    document_type "employment_appeal_tribunal_decision"

    transient do
      default_metadata {
        {
          "tribunal_decision_categories" => ["age-discrimination"],
          "tribunal_decision_decision_date" => "2015-07-30",
          "tribunal_decision_landmark" => "landmark",
          "tribunal_decision_sub_categories" => ["contract-of-employment-apprenticeship"],
          "document_type" => "employment_appeal_tribunal_decision",
        }
      }
    end
  end

  factory :employment_tribunal_decision, parent: :document do
    base_path "/employment-tribunal-decisions/example-employment-tribunal-decision"
    document_type "employment_tribunal_decision"

    transient do
      default_metadata {
        {
          "tribunal_decision_categories" => ["age-discrimination"],
          "tribunal_decision_country" => "england-and-wales",
          "tribunal_decision_decision_date" => "2015-07-30",
          "document_type" => "employment_tribunal_decision",
        }
      }
    end
  end

  factory :esi_fund, parent: :document do
    base_path "/european-structural-investment-funds/example-esi-fund"
    document_type "esi_fund"

    transient do
      default_metadata {
        {
          "closing_date" => "2016-01-01",
          "document_type" => "esi_fund",
        }
      }
    end
  end

  factory :maib_report, parent: :document do
    base_path "/maib-reports/example-maib-report"
    document_type "maib_report"

    transient do
      default_metadata {
        {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "maib_report",
        }
      }
    end
  end

  factory :medical_safety_alert, parent: :document do
    base_path "/drug-device-alerts/example-medical-safety-alert"
    document_type "medical_safety_alert"

    transient do
      default_metadata {
        {
          "alert_type" => "company-led-drugs",
          "issued_date" => "2016-02-01",
          "document_type" => "medical_safety_alert",
        }
      }
    end
  end

  factory :raib_report, parent: :document do
    base_path "/raib-reports/example-raib-report"
    document_type "raib_report"

    transient do
      default_metadata {
        {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "raib_report",
        }
      }
    end
  end

  factory :tax_tribunal_decision, parent: :document do
    base_path "/tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision"
    document_type "tax_tribunal_decision"

    transient do
      default_metadata {
        {
          "tribunal_decision_category" => "banking",
          "tribunal_decision_decision_date" => "2015-07-30",
          "document_type" => "tax_tribunal_decision",
        }
      }
    end
  end

  factory :vehicle_recalls_and_faults_alert, parent: :document do
    base_path "/vehicle-recalls-faults/example-vehicle-recalls-and-faults"
    document_type "vehicle_recalls_and_faults_alert"

    transient do
      default_metadata {
        {
          "alert_issue_date" => "2015-04-28",
          "build_start_date" => "2015-04-28",
          "build_end_date" => "2015-06-28",
          "document_type" => "vehicle_recalls_and_faults_alert",
        }
      }
    end
  end
end
