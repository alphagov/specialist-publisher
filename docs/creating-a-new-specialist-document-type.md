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

## 4. Deploy and publish

Yes, deploy your code to the relevant environment. Publish an example of your new document.

## 5 Run the rake task to publish all finders

You'll need to manually run the [`publishing_api:publish_finders`](lib/tasks/publishing_api.rake) rake task to ensure that the finders are correctly published and that all metadata and facets for your new document type are made available.

You can do this through Jenkins or, if you are running from the console, the following will run the rake task:

```
sudo -u deploy govuk_setenv specialist-publisher bundle exec rake publishing_api:publish_finders
```

## 6 Reindex rummager

On one of the `search-api` boxes, `cd` to `/var/apps/rummager` and run this rake task. This will take some time (at writing a few hours).

```
govuk_setenv rummager bundle exec rake rummager:migrate_schema CONFIRM_INDEX_MIGRATION_START=1 RUMMAGER_INDEX=govuk
```
