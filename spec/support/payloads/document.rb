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
end
