module Payloads
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
        "body" => "## Header" + ("\r\n\r\nThis is the long body of an example CMA case" * 10),
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

  def self.manual_content_item(attr = {})
    {
      "base_path" => "/guidance/a-manual",
      "content_id" => "b1dc075f-d946-4bcb-a5eb-941f8c8188cf",
      "description" => "A manual description",
      "details" => {
        "body" => "A manual body",
        "child_section_groups" => [
          {
            "title" => "Contents",
            "child_sections" => [
              {
                "title" => "First section",
                "description" => "This is a manual's first section",
                "base_path" => "/guidance/a-manual/first-section"
              },
              {
                "title" => "Second section",
                "description" => "This is a manual's second section",
                "base_path" => "/guidance/a-manual/second-section"
              },
            ]
          }
        ],
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
        ],
        "organisations" => [
          {
            "title" => "Goverment Digital Service",
            "abbreviation" => "GDS",
            "web_url" => "https://www.gov.uk/government/organisations/government-digital-service"
          }
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
    }.merge(attr)
  end

  def self.section_content_items
    [
      {
        "base_path" => "/guidance/a-manual/first-section",
        "content_id" => "7df32e1b-d92c-4e63-8c74-7922c408cfd5",
        "description" => "This is a manual's first section",
        "details" => {
          "body" => "First section body",
          "organisations" => [
            {
              "title" => "Goverment Digital Service",
              "abbreviation" => "DVSA",
              "web_url" => "https://www.gov.uk/government/organisations/government-digital-service"
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
          "organisations" => [
            {
              "title" => "Goverment Digital Service",
              "abbreviation" => "DVSA",
              "web_url" => "https://www.gov.uk/government/organisations/government-digital-service"
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
