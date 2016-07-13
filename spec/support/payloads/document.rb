module Payloads
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
      "document_type" => "manual",
      "schema_name" => "manual",
      "locale" => "en",
      "public_updated_at" => "2016-02-02T12:28:41.000Z",
      "updated_at" => "2016-02-01T12:28:41.000Z",
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
        "updated_at" => "2016-02-01T12:28:41.000Z",
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
        "updated_at" => "2016-02-01T12:28:41.000Z",
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
