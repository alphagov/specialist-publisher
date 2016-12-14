# Creating a new specialist document type

To create a new specialist document you will have to make changes to this
application, [govuk-content-schemas][govuk-content-schemas] and
[rummager][rummager]. You will not have to make any changes to frontend
applications.

## 1. Configure the specialist document schema

You'll have to make sure that when this app sends new documents to the
publishing-api it can validate your request against the
[govuk-content-schemas][govuk-content-schemas].

## 2. Configure rummager

You'll need to add the document type to search (the [rummager][rummager] application), so that it can
index the new documents.

[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[rummager]: https://github.com/alphagov/rummager

## 3. Configure specialist-publisher

You could use the [PR to create the International Development Fund](https://github.com/alphagov/specialist-publisher/pull/855) document as a
template.

The two most important things here are the document class, like [`AaibReport`](/app/models/aaib_report.rb), and the finder configuration file, like [aaib_reports.json](/lib/documents/schemas/aaib_reports.json).
