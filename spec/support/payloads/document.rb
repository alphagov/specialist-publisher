module Payloads
  def self.aaib_report_content_item(attrs = {})
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/aaib-reports/example-aaib-report",
      "title" => "Example AAIB Report",
      "description" => "This is the summary of example AAIB Report",
      "document_type" => "aaib_report",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example AAIB Report" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example AAIB Report</p>\n" * 10)
          }
        ],
        "metadata" => {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "aaib_report"
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/aaib-reports/example-aaib-report",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.employment_appeal_tribunal_decision_content_item(attrs = {})
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision",
      "title" => "Example Employment Appeal Tribunal Decision",
      "description" => "This is the summary of example Employment Appeal Tribunal Decision",
      "document_type" => "employment_appeal_tribunal_decision",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Employment Appeal Tribunal Decision" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Employment Appeal Tribunal Decision</p>\n" * 10)
          }
        ],
        "metadata" => {
          "tribunal_decision_categories" => ["age-discrimination"],
          "tribunal_decision_decision_date" => "2015-07-30",
          "tribunal_decision_landmark" => "landmark",
          "tribunal_decision_sub_categories" => ["contract-of-employment-apprenticeship"],
          "document_type" => "employment_appeal_tribunal_decision",
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/employment-appeal-tribunal-decisions/example-employment-appeal-tribunal-decision",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.cma_case_content_item(attrs = {})
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/cma-cases/example-cma-case",
      "title" => "Example CMA Case",
      "description" => "This is the summary of an example CMA case",
      "document_type" => "cma_case",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-12-03T16:59:13+00:00",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example CMA case</p>\n" * 10)
          }
        ],
        "metadata" => {
          "opened_date" => "2014-01-01",
          "case_type" => "ca98-and-civil-cartels",
          "case_state" => "open",
          "market_sector" => ["energy"],
          "document_type" => "cma_case",
        },
        "change_history" => [
          {
            "public_timestamp" => "2015-12-03T16:59:13+00:00",
            "note" => "First published."
          }
        ]
      },
      "routes" => [
        {
          "path" => "/cma-cases/example-cma-case",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.countryside_stewardship_grant_content_item(attrs = {})
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/countryside-stewardship-grants/example-countryside-stewardship-grant",
      "title" => "Example Countryside Stewardship Grant",
      "description" => "This is the summary of example Countryside Stewardship Grant",
      "document_type" => "countryside_stewardship_grant",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Countryside Stewardship Grant" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Countryside Stewardship Grant</p>\n" * 10)
          }
        ],
        "metadata" => {
          "document_type" => "countryside_stewardship_grant"
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/countryside-stewardship-grants/example-countryside-stewardship-grant",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.drug_safety_update_content_item(attrs = {})
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/drug-safety-update/example-drug-safety-update",
      "title" => "Example Drug Safety Update",
      "description" => "This is the summary of an example Drug Safety Update",
      "document_type" => "drug_safety_update",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Drug Safety Update" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Drug Safety Update</p>\n" * 10)
          }
        ],
        "metadata" => {
          "document_type" => "drug_safety_update",
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/drug-safety-update/example-drug-safety-update",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.employment_tribunal_decision_content_item(attrs)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/employment-tribunal-decisions/example-employment-tribunal-decision",
      "title" => "Example Employment Tribunal Decision",
      "description" => "This is the summary of example Employment Tribunal Decision",
      "document_type" => "employment_tribunal_decision",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Employment Tribunal Decision" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Employment Tribunal Decision</p>\n" * 10)
          }
        ],
        "metadata" => {
          "tribunal_decision_categories" => ["age-discrimination"],
          "tribunal_decision_country" => "england-and-wales",
          "tribunal_decision_decision_date" => "2015-07-30",
          "document_type" => "employment_tribunal_decision",
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/employment-tribunal-decisions/example-employment-tribunal-decision",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.esi_fund_content_item(attrs)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/european-structural-investment-funds/example-esi-fund",
      "title" => "Example ESI Fund",
      "description" => "This is the summary of example ESI Fund",
      "document_type" => "esi_fund",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example ESI Fund" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example ESI Fund</p>\n" * 10)
          }
        ],
        "metadata" => {
          "closing_date" => "2016-01-01",
          "document_type" => "esi_fund",
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/european-structural-investment-funds/example-esi-fund",
          "type" => "exact",
        },
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.maib_report_content_item(attrs)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/maib-reports/example-maib-report",
      "title" => "Example MAIB Report",
      "description" => "This is the summary of example MAIB Report",
      "document_type" => "maib_report",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example MAIB Report" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example MAIB Report</p>\n" * 10)
          }
        ],
        "metadata" => {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "maib_report"
        },
      },
      "routes" => [
        {
          "path" => "/maib-reports/example-maib-report",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.medical_safety_alert_content_item(attrs = {})
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/drug-device-alerts/example-medical-safety-alert",
      "title" => "Example Medical Safety Alert",
      "description" => "This is the summary of example Medical Safety Alert",
      "document_type" => "medical_safety_alert",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Medical Safety Alert" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Medical Safety Alert</p>\n" * 10)
          }
        ],
        "metadata" => {
          "alert_type" => "company-led-drugs",
          "issued_date" => "2016-02-01",
          "document_type" => "medical_safety_alert"
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/drug-device-alerts/example-medical-safety-alert",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.raib_report_content_item(attrs)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/raib-reports/example-raib-report",
      "title" => "Example RAIB Report",
      "description" => "This is the summary of example RAIB Report",
      "document_type" => "raib_report",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example RAIB Report" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example RAIB Report</p>\n" * 10)
          }
        ],
        "metadata" => {
          "date_of_occurrence" => "2015-10-10",
          "document_type" => "raib_report"
        },
      },
      "routes" => [
        {
          "path" => "/raib-reports/example-raib-report",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.tax_tribunal_decision_content_item(attrs)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision",
      "title" => "Example Tax Tribunal Decision",
      "description" => "This is the summary of example Tax Tribunal Decision",
      "document_type" => "tax_tribunal_decision",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Tax Tribunal Decision" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Tax Tribunal Decision</p>\n" * 10)
          }
        ],
        "metadata" => {
          "tribunal_decision_category" => "banking",
          "tribunal_decision_decision_date" => "2015-07-30",
          "document_type" => "tax_tribunal_decision",
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/tax-and-chancery-tribunal-decisions/example-tax-tribunal-decision",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.vehicle_recalls_and_faults_alert_content_item(attrs)
    {
      "content_id" => SecureRandom.uuid,
      "base_path" => "/vehicle-recalls-faults/example-vehicle-recalls-and-faults",
      "title" => "Example Vehicle Recalls And Faults",
      "description" => "This is the summary of example Vehicle Recalls And Faults",
      "document_type" => "vehicle_recalls_and_faults_alert",
      "schema_name" => "specialist_document",
      "publishing_app" => "specialist-publisher",
      "rendering_app" => "specialist-frontend",
      "locale" => "en",
      "phase" => "live",
      "public_updated_at" => "2015-11-16T11:53:30",
      "publication_state" => "draft",
      "details" => {
        "body" => [
          {
            "content_type" => "text/govspeak",
            "content" => "## Header" + ("\r\n\r\nThis is the long body of an example Vehicle Recalls And Faults" * 10)
          },
          {
            "content_type" => "text/html",
            "content" => ("<h2 id=\"header\">Header</h2>\n" + "\n<p>This is the long body of an example Vehicle Recalls And Faults</p>\n" * 10)
          }
        ],
        "metadata" => {
          "alert_issue_date" => "2015-04-28",
          "build_start_date" => "2015-04-28",
          "build_end_date" => "2015-06-28",
          "document_type" => "vehicle_recalls_and_faults_alert"
        },
        "change_history" => [],
      },
      "routes" => [
        {
          "path" => "/vehicle-recalls-faults/example-vehicle-recalls-and-faults",
          "type" => "exact",
        }
      ],
      "redirects" => [],
      "update_type" => "major",
    }.deep_merge(attrs)
  end

  def self.manual_content_item(attr = {})
    {
      "base_path" => "/guidance/a-manual",
      "content_id" => "b1dc075f-d946-4bcb-a5eb-941f8c8188cf",
      "description" => "A manual description",
      "details" => {
        "body" => "A manual body",
        "change_notes" => [
          {
            "base_path" => "/guidance/a-manual/first-section",
            "title" => "First section",
            "change_note" => "New section added.",
            "published_at" => "2015-12-23T14:38:51+00:00"
          },
          {
            "base_path" => "/guidance/a-manual/second-section",
            "title" => "Second section",
            "change_note" => "New section added.",
            "published_at" => "2015-12-23T14:38:51+00:00"
          },
        ]
      },
      "format" => "manual",
      "locale" => "en",
      "public_updated_at" => "2016-02-02T12:28:41.000Z",
      "publishing_app" => "specialist-publisher",
      "redirects" => [],
      "rendering_app" => "manuals-frontend",
      "routes" => [
        {
          "path" => "/guidance/a-manual",
          "type" => "exact"
        },
        {
          "path" => "/guidance/a-manual/updates",
          "type" => "exact"
        }
      ],
      "title" => "A Manual",
      "analytics_identifier" => nil,
      "phase" => "live",
      "update_type" => "major",
      "need_ids" => [],
      "publication_state" => "live",
      "live_version" => 2,
      "version" => 2
    }.merge(attr)
  end

  def self.manual_links(attr = {})
    {
      "content_id" => "b1dc075f-d946-4bcb-a5eb-941f8c8188cf",
      "links" => {
        "sections" => [
          "f12895fc-58d8-417a-a762-2a5fb2266d63",
          "7df32e1b-d92c-4e63-8c74-7922c408cfd5",
        ],
        "organisations" => [
          "af07d5a5-df63-4ddc-9383-6a666845ebe9"
        ]
      }
    }.deep_merge(attr)
  end

  def self.section_content_items
    [
      {
        "base_path" => "/guidance/a-manual/first-section",
        "content_id" => "7df32e1b-d92c-4e63-8c74-7922c408cfd5",
        "description" => "This is a manual's first section",
        "details" => {
          "body" => "First section body",
        },
        "format" => "manual_section",
        "locale" => "en",
        "public_updated_at" => "2016-02-02T12:28:41.000Z",
        "publishing_app" => "specialist-publisher",
        "redirects" => [],
        "rendering_app" => "manuals-frontend",
        "routes" => [
          {
            "path" => "/guidance/a-manual/first-section",
            "type" => "exact"
          }
        ],
        "title" => "First section",
        "analytics_identifier" => nil,
        "phase" => "live",
        "update_type" => "major",
        "need_ids" => [],
        "publication_state" => "live",
        "live_version" => 2,
        "version" => 2
      },
      {
        "base_path" => "/guidance/a-manual/second-section",
        "content_id" => "f12895fc-58d8-417a-a762-2a5fb2266d63",
        "description" => "This is a manual's second section",
        "details" => {
          "body" => "Second section body",
          "attachments" => [
            {
              "content_id" => "77f2d40e-3853-451f-9ca3-a747e8402e34",
              "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/section-image.jpg",
              "content_type" => "application/jpeg",
              "title" => "section image title",
              "created_at" => "2015-12-03T16:59:13+00:00",
              "updated_at" => "2015-12-03T16:59:13+00:00"
            },
            {
              "content_id" => "ec3f6901-4156-4720-b4e5-f04c0b152141",
              "url" => "https://assets.digital.cabinet-office.gov.uk/media/513a0efbed915d425e000002/section-pdf.pdf",
              "content_type" => "application/pdf",
              "title" => "section pdf title",
              "created_at" => "2015-12-03T16:59:13+00:00",
              "updated_at" => "2015-12-03T16:59:13+00:00"
            }
          ]
        },
        "format" => "manual_section",
        "locale" => "en",
        "public_updated_at" => "2016-02-02T12:28:41.000Z",
        "publishing_app" => "specialist-publisher",
        "redirects" => [],
        "rendering_app" => "manuals-frontend",
        "routes" => [
          {
            "path" => "/guidance/a-manual/second-section",
            "type" => "exact"
          }
        ],
        "title" => "Second section",
        "analytics_identifier" => nil,
        "phase" => "live",
        "update_type" => "major",
        "need_ids" => [],
        "publication_state" => "live",
        "live_version" => 2,
        "version" => 2
      },
    ]
  end

  def self.section_links
    [
      {
        "content_id" => "7df32e1b-d92c-4e63-8c74-7922c408cfd5",
        "links" => {
          "manual" => [
            "b1dc075f-d946-4bcb-a5eb-941f8c8188cf"
          ],
          "organisations" => [
            "af07d5a5-df63-4ddc-9383-6a666845ebe9"
          ]
        }
      },
      {
        "content_id" => "f12895fc-58d8-417a-a762-2a5fb2266d63",
        "links" => {
          "manual" => [
            "b1dc075f-d946-4bcb-a5eb-941f8c8188cf"
          ],
          "organisations" => [
            "af07d5a5-df63-4ddc-9383-6a666845ebe9"
          ]
        }
      }
    ]
  end
end
