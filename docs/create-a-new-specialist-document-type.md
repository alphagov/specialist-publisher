# Create a new specialist document format

To create a new specialist document you will have to make changes to this
application, [govuk-content-schemas][govuk-content-schemas] and
[search-api][search-api]. You will not have to make any changes to frontend
applications.

[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[search-api]: https://github.com/alphagov/search-api

## Create a new specialist document format in Specialist Publisher

### Create the schema

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/lib/documents/schemas/cma_cases.json).

You'll need to generate your own UUIDs for it, e.g.:
```
$ irb
irb(main):001:0> require "securerandom"
=> true
irb(main):002:0> SecureRandom.uuid
=> "5087e8b6-ee54-40f9-b592-8c2813c7037d"
```

### Create the model

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/models/cma_case.rb)

### Create the view template

[CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/views/metadata_fields/_cma_cases.html.erb)

## Configure Search API

### Add the schema

Search API needs a copy of a schema very similar to the one in Specialist Publisher.

See [the CMA case schema](https://github.com/alphagov/search-api/blob/main/config/schema/elasticsearch_types/cma_case.json), [the main ES types list](https://github.com/alphagov/search-api/blob/main/config/schema/indexes/govuk.json) and [the field definitions](https://github.com/alphagov/search-api/blob/1700c85e1484d1d9b2c1d46f276326bc06b51a14/config/schema/field_definitions.json).

### Tell Search API about the format

- [migrated_formats.yaml](https://github.com/alphagov/search-api/blob/main/config/govuk_index/migrated_formats.yaml)
- [mapped_document_types.yaml](https://github.com/alphagov/search-api/blob/main/config/govuk_index/mapped_document_types.yaml)
- [elasticsearch_presenter.rb](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/elasticsearch_presenter.rb)
- [specialist_presenter.rb](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/specialist_presenter.rb)

## Add a schema to govuk-content-schemas

1. Add the format to [this list](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/specialist_document.jsonnet#L2-L22)
2. Add any new field definitions to [this file](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/shared/definitions/_specialist_document.jsonnet)
3. Add examples [as instructed](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/adding-a-new-schema.md#examples)
4. Follow the rest of [the workflow](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/suggested-workflows.md)

## Configure the email sign up page

The email sign up page is rendered by finder frontend using the configuration in the new schema added to specialist publisher. However, if the email sign up page has check boxes (eg [cma-cases](https://www.gov.uk/cma-cases/email-signup)), you must add the new tags to [this file](https://github.com/alphagov/email-alert-api/blob/3e0018510ea85f5d561e2865ad149832b94688a1/lib/valid_tags.rb#L2) in email-alert-api.

## Consider the signon permissions needed to publish this new document

By default, specialist-publisher grants access to the publishing interface for your new document type to the following signon users:
 - Users that belong to the owner organisation AND have Editor permissions
 - Users that have the permission your_new_document_type_editor. Eg oim_project_editor

## Deploy and publish

Once you're ready to ship your code to an environment,

1. Deploy Specialist Publisher, Search API, and govuk-content-schemas.
2. Reindex the govuk Elasticsearch index by following the steps [here](https://docs.publishing.service.gov.uk/manual/reindex-elasticsearch.html#how-to-reindex-an-elasticsearch-index). This takes around 30-45 minutes on Production, or 3-4 hours on Integration.
3. Use the "Run rake task" Jenkins job to run `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app on a backend machine.
