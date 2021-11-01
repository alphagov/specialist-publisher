# Create a new specialist document format

To create a new specialist document you will have to make changes to this
application, [govuk-content-schemas][govuk-content-schemas] and
[search-api][search-api]. You will not have to make any changes to frontend
applications.

[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[search-api]: https://github.com/alphagov/search-api

## Add a schema to govuk-content-schemas

See example [PR for adding `product_safety_alert`](https://github.com/alphagov/govuk-content-schemas/pull/1077).

1. Add the format to [this list](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/specialist_document.jsonnet#L2-L22) and to [this list](https://github.com/alphagov/govuk-content-schemas/blob/main/lib/govuk_content_schemas/allowed_document_types.yml)
2. Add any new field definitions to [this file](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/shared/definitions/_specialist_document.jsonnet)
3. Add examples [as instructed](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/adding-a-new-schema.md#examples).
   You can copy and paste from another specialist document format, only changing what is necessary (you can leave the body and headers unchanged).

You'll need to generate your own UUIDs for the `content_id` and `signup_content_id` fields:

```
$ irb
irb(main):001:0> require "securerandom"
=> true
irb(main):002:0> SecureRandom.uuid
=> "5087e8b6-ee54-40f9-b592-8c2813c7037d"
```

When the PR is reviewed and its tests passing, it can be merged and deployed at this point.

## Create a new specialist document format in Specialist Publisher

### Create the schema

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/lib/documents/schemas/cma_cases.json).

New formats are often requested to be deployed in "pre-production mode", which is configured in this step ([example](https://github.com/alphagov/specialist-publisher/blob/f8e93142dfad6f3971a73c923b01f2e7352bdb54/lib/documents/schemas/tax_tribunal_decisions.json#L64)). `pre-production` documents are only publishable on development and integration.

### Create the model

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/models/cma_case.rb)

### Create the view template

[CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/views/metadata_fields/_cma_cases.html.erb)

## Configure Search API

Search API needs copies of the schema very similar to the one in Specialist Publisher. See:

- [CMA case schema](https://github.com/alphagov/search-api/blob/main/config/schema/elasticsearch_types/cma_case.json) (example)
- [field definitions](https://github.com/alphagov/search-api/blob/1700c85e1484d1d9b2c1d46f276326bc06b51a14/config/schema/field_definitions.json)

You'll also need to add your document format to:

- the main ES types list [govuk.json](https://github.com/alphagov/search-api/blob/main/config/schema/indexes/govuk.json)
- [migrated_formats.yaml](https://github.com/alphagov/search-api/blob/main/config/govuk_index/migrated_formats.yaml)
- [mapped_document_types.yaml](https://github.com/alphagov/search-api/blob/main/config/govuk_index/mapped_document_types.yaml)

Finally, you'll need to add your custom fields to:

- [elasticsearch_presenter.rb](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/elasticsearch_presenter.rb)
- [specialist_presenter.rb](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/specialist_presenter.rb)

## Configure the email sign up page

The email sign up page is rendered by [Finder Frontend](https://github.com/alphagov/finder-frontend) using the configuration in the new schema added to specialist publisher.

If your email sign up page should have checkboxes (e.g. [cma-cases](https://www.gov.uk/cma-cases/email-signup)), you will need to edit email-alert-api by adding the new tags to [valid_tags.rb](https://github.com/alphagov/email-alert-api/blob/3e0018510ea85f5d561e2865ad149832b94688a1/lib/valid_tags.rb#L2).

## Deploy and publish

To deploy:

1. Deploy Specialist Publisher and Search API (and govuk-content-schemas if you haven't already).
2. [Reindex the govuk Elasticsearch index](https://docs.publishing.service.gov.uk/manual/reindex-elasticsearch.html#how-to-reindex-an-elasticsearch-index). This takes around 30-45 minutes on Production, or 3-4 hours on Integration.
3. Use the "Run rake task" Jenkins job to run `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app on a backend machine.

## Permissions

Specialist Publisher grants access to the publishing interface for your new document type to the following Signon users:

 - Users that belong to the owner organisation AND have `Editor` permissions
 - Users that have the permission `your_new_document_type_editor`, e.g. `oim_project_editor`