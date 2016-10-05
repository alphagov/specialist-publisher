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

  # Editor factories:
  factory :editor, parent: :user do
    permissions %w(signin editor)
  end

  factory :gds_editor, parent: :user do
    organisation_slug "government-digital-service"
    permissions %w(signin gds_editor)
  end

  factory :cma_editor, parent: :editor do
    organisation_slug "competition-and-markets-authority"
    organisation_content_id "957eb4ec-089b-4f71-ba2a-dc69ac8919ea"
  end

  factory :moj_editor, parent: :editor do
    organisation_slug "ministry-of-justice"
    organisation_content_id "dcc907d6-433c-42df-9ffb-d9c68be5dc4d"
  end

  factory :incorrect_id_editor, parent: :editor do
    organisation_slug "competition-and-markets-authority"
    organisation_content_id "ycd9e3dh-222g-3h5f-gsaa-v2f28berrc3a"
  end

  factory :aaib_editor, parent: :editor do
    organisation_slug "air-accidents-investigation-branch"
    organisation_content_id "38eb5d8f-2d89-480c-8655-e2e7ac23f8f4"
  end

  factory :dfid_editor, parent: :editor do
    organisation_slug "department-for-international-development"
    organisation_content_id "db994552-7644-404d-a770-a2fe659c661f"
  end

  # Writer factories:
  factory :writer, aliases: [:cma_writer], parent: :editor do
    organisation_slug "competition-and-markets-authority"
    organisation_content_id "957eb4ec-089b-4f71-ba2a-dc69ac8919ea"
    permissions %w(signin)
  end

  factory :moj_writer, parent: :writer do
    organisation_slug "ministry-of-justice"
    organisation_content_id "dcc907d6-433c-42df-9ffb-d9c68be5dc4d"
  end

  sequence :content_id do |_|
    SecureRandom.uuid
  end

  factory :document, class: Hash do
    content_id
    base_path "/example-document"
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
    first_published_at nil
    last_edited_at "2015-11-15T11:53:30"
    publication_state "draft"
    state_history {
      { "1": "draft" }
    }

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
              "content" => "default text"
            }
          ],
          "metadata" => default_metadata,
          "max_cache_time" => 10,
          "change_history" => change_history,
          "temporary_update_type" => false,
        }
      }
      change_history { [] }
      default_metadata { {} }
    end

    initialize_with {
      merged_details = default_details.deep_stringify_keys.deep_merge(details.deep_stringify_keys)
      attributes.merge(details: merged_details)
    }

    # This is the default document state.
    trait :draft do
    end

    trait :published do
      publication_state 'published'
      first_published_at "2015-11-15T00:00:00+00:00"
      state_history {
        { "1": "published" }
      }

      change_history do
        [
          {
            'public_timestamp' => Time.current.iso8601,
            'note' => "First published.",
          }
        ]
      end
    end

    trait :redrafted do
      state_history {
        { "2": "draft", "1": "published" }
      }

      publication_state 'draft'
      first_published_at "2015-11-15T00:00:00+00:00"

      update_type "major"
      change_history do
        [
            {
                'public_timestamp' => Time.current.iso8601,
                'note' => "First published.",
            },
        ]
      end
    end

    trait :unpublished do
      publication_state 'unpublished'
      first_published_at "2015-11-15T00:00:00+00:00"
      state_history {
        { "1": "unpublished" }
      }

      change_history do
        [
          {
            'public_timestamp' => Time.current.iso8601,
            'note' => "First published.",
          }
        ]
      end
    end

    to_create(&:deep_stringify_keys!)
  end

  factory :aaib_report, parent: :document do
    base_path "/aaib-reports/example-document"
    document_type "aaib_report"

    transient do
      default_metadata {
        {
          "date_of_occurrence" => "2015-10-10",
          "aircraft_category" => ["commercial-fixed-wing"],
          "report_type" => "annual-safety-report",
          "location" => "Near Popham Airfield, Hampshire",
          "aircraft_type" => "Alpi (Cavaciuti) Pioneer 400",
          "registration" => "G-CGVO",
        }
      }
    end
  end

  factory :asylum_support_decision, parent: :document do
    base_path "/asylum-support-tribunal-decisions/example-document"
    document_type "asylum_support_decision"

    transient do
      default_metadata {
        {
          "hidden_indexable_content" => "some hidden content",
          "tribunal_decision_category" => "section-95-support-for-asylum-seekers",
          "tribunal_decision_decision_date" => "2015-10-10",
          "tribunal_decision_judges" => ["bayati-c"],
          "tribunal_decision_landmark" => "not-landmark",
          "tribunal_decision_reference_number" => "1234567890",
          "tribunal_decision_sub_category" => "section-95-destitution",
        }
      }
    end
  end

  factory :cma_case, parent: :document do
    base_path "/cma-cases/example-document"
    document_type "cma_case"

    transient do
      default_metadata {
        {
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
    base_path "/countryside-stewardship-grants/example-document"
    document_type "countryside_stewardship_grant"

    transient do
      default_metadata {
        {
          "grant_type" => "option",
          "land_use" => ["priority-habitats", "trees-non-woodland", "uplands"],
          "tiers_or_standalone_items" => ["higher-tier"],
          "funding_amount" => ["201-to-300"],
        }
      }
    end
  end

  factory :dfid_research_output, parent: :document do
    base_path "/dfid-research-outputs/example-document"
    document_type "dfid_research_output"

    transient do
      default_metadata {
        {
          "dfid_document_type" => "book_chapter",
          "country" => ["GB"],
          "dfid_authors" => ["Mr. Potato Head", "Mrs. Potato Head"],
          "dfid_theme" => ["infrastructure"],
          "first_published_at" => "2016-04-28",
          "bulk_published" => true
        }
      }
    end
  end

  factory :drug_safety_update, parent: :document do
    base_path "/drug-safety-update/example-document"
    document_type "drug_safety_update"

    transient do
      default_metadata {
        {
          "therapeutic_area" => ["cancer", "haematology", "immunosuppression-transplantation"],
        }
      }
    end
  end

  factory :employment_appeal_tribunal_decision, parent: :document do
    base_path "/employment-appeal-tribunal-decisions/example-document"
    document_type "employment_appeal_tribunal_decision"

    transient do
      default_metadata {
        {
          "tribunal_decision_categories" => ["age-discrimination"],
          "tribunal_decision_decision_date" => "2015-07-30",
          "tribunal_decision_landmark" => "landmark",
          "tribunal_decision_sub_categories" => ["contract-of-employment-apprenticeship"],
          "hidden_indexable_content" => "???",
        }
      }
    end
  end

  factory :employment_tribunal_decision, parent: :document do
    base_path "/employment-tribunal-decisions/example-document"
    document_type "employment_tribunal_decision"

    transient do
      default_metadata {
        {
          "tribunal_decision_categories" => ["age-discrimination"],
          "tribunal_decision_country" => "england-and-wales",
          "tribunal_decision_decision_date" => "2015-07-30",
          "hidden_indexable_content" => "???",
        }
      }
    end
  end

  factory :esi_fund, parent: :document do
    base_path "/european-structural-investment-funds/example-document"
    document_type "esi_fund"

    transient do
      default_metadata {
        {
          "closing_date" => "2016-01-01",
          "fund_state" => "open",
          "fund_type" => ["business-support"],
          "location" => ["south-west"],
          "funding_source" => ["european-regional-development-fund"],
        }
      }
    end
  end

  factory :international_development_fund, parent: :document do
    base_path "/international-development-funding/example-document"
    document_type "international_development_fund"

    transient do
      default_metadata {
        {
          "fund_state" => "open",
          "location" => ["ghana"],
          "development_sector" => ["climate-change"],
          "eligible_entities" => ["non-governmental-organisations"],
          "value_of_funding" => ["up-to-100000"],
        }
      }
    end
  end

  factory :maib_report, parent: :document do
    base_path "/maib-reports/example-document"
    document_type "maib_report"

    transient do
      default_metadata {
        {
          "date_of_occurrence" => "2015-10-10",
          "report_type" => "investigation-report",
          "vessel_type" => ["merchant-vessel-100-gross-tons-or-over"],
        }
      }
    end
  end

  factory :medical_safety_alert, parent: :document do
    base_path "/drug-device-alerts/example-document"
    document_type "medical_safety_alert"

    transient do
      default_metadata {
        {
          "alert_type" => "company-led-drugs",
          "issued_date" => "2016-02-01",
          "medical_specialism" => %w(anaesthetics cardiology),
        }
      }
    end
  end

  factory :raib_report, parent: :document do
    base_path "/raib-reports/example-document"
    document_type "raib_report"

    transient do
      default_metadata {
        {
          "date_of_occurrence" => "2015-10-10",
          "report_type" => "investigation-report",
          "railway_type" => ["heavy-rail"],
        }
      }
    end
  end

  factory :tax_tribunal_decision, parent: :document do
    base_path "/tax-and-chancery-tribunal-decisions/example-document"
    document_type "tax_tribunal_decision"

    transient do
      default_metadata {
        {
          "tribunal_decision_category" => "banking",
          "tribunal_decision_decision_date" => "2015-07-30",
          "hidden_indexable_content" => "???",
        }
      }
    end
  end

  factory :utaac_decision, parent: :document do
    base_path "/administrative-appeals-tribunal-decisions/example-document"
    document_type "utaac_decision"

    transient do
      default_metadata {
        {
            "tribunal_decision_categories" => ["Benefits for children"],
            "tribunal_decision_decision_date" => "2016-01-01",
            "tribunal_decision_judges" => ["angus-r"],
            "tribunal_decision_sub_categories" => ["benefits-for-children-benefit-increases-for-children"],
            "hidden_indexable_content" => "???"
        }
      }
    end
  end

  factory :vehicle_recalls_and_faults_alert, parent: :document do
    base_path "/vehicle-recalls-faults/example-document"
    document_type "vehicle_recalls_and_faults_alert"

    transient do
      default_metadata {
        {
          "alert_issue_date" => "2015-04-28",
          "build_start_date" => "2015-04-28",
          "build_end_date" => "2015-06-28",
          "fault_type" => "recall",
          "faulty_item_type" => "other-accessories",
          "manufacturer" => "nim-engineering-ltd",
          "faulty_item_model" => "Cable Recovery Winch",
          "serial_number" => "SN123",
        }
      }
    end
  end

  factory :my_document_type, parent: :document do
    base_path "/base-path-for-my-document-type"
    document_type "my_document_type"
  end

  factory :attachment_payload, class: Hash do
    content_id
    sequence(:url) { |n|
      "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/asylum-support-image-#{n}.jpg"
    }
    content_type "application/jpeg"
    title "asylum report image title"
    created_at "2015-12-18T10:12:26+00:00"
    updated_at "2015-12-18T10:12:26+00:00"

    initialize_with { attributes }
    to_create(&:deep_stringify_keys!)
  end
end
