# Creating a new specialist document format

To create a new specialist document you will have to make changes to this
application, [govuk-content-schemas][govuk-content-schemas] and
[rummager][rummager]. You will not have to make any changes to frontend
applications.

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

## Configure rummager

### Add the schema

Rummager needs a copy of a schema very similar to the one in Specialist Publisher.

See [the CMA case schema](https://github.com/alphagov/rummager/blob/main/config/schema/elasticsearch_types/cma_case.json), [the main ES types list](https://github.com/alphagov/rummager/blob/main/config/schema/indexes/govuk.json) and [the field definitions](https://github.com/alphagov/rummager/blob/1700c85e1484d1d9b2c1d46f276326bc06b51a14/config/schema/field_definitions.json).

### Tell Rummager about the format

- [migrated_formats.yaml](https://github.com/alphagov/rummager/blob/main/config/govuk_index/migrated_formats.yaml)
- [mapped_document_types.yaml](https://github.com/alphagov/rummager/blob/main/config/govuk_index/mapped_document_types.yaml)
- [elasticsearch_presenter.rb](https://github.com/alphagov/rummager/blob/main/lib/govuk_index/presenters/elasticsearch_presenter.rb)
- [specialist_presenter.rb](https://github.com/alphagov/rummager/blob/main/lib/govuk_index/presenters/specialist_presenter.rb)

## Add a schema to govuk-content-schemas

1. Add the format to [this list](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/specialist_document.jsonnet#L2-L22)
2. Add any new field definitions to [this file](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/shared/definitions/_specialist_document.jsonnet)
3. Add examples [as instructed](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/adding-a-new-schema.md#examples)
4. Follow the rest of [the workflow](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/suggested-workflows.md)

## Deploy and publish

Once you're ready to ship your code to an environment,

1. Deploy Specialist Publisher, Rummager, and govuk-content-schemas.
2. Run the "Search reindex for new schema" Jenkins job.  This takes around 30-45 minutes on Production, or 3-4 hours on Integration.
3. Use the "Run rake task" Jenkins job to run `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app on a backend machine.
