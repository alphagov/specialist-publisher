# Creating a new specialist document format

To create a new specialist document you will have to make changes to this
application, [govuk-content-schemas][govuk-content-schemas] and
[rummager][rummager]. You will not have to make any changes to frontend
applications.

## Create a new specialist document format in Specialist Publisher

### Create the schema

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/master/lib/documents/schemas/cma_cases.json).

You'll need to generate your own UUIDs for it, e.g.:
```
$ irb
irb(main):001:0> require "securerandom"
=> true
irb(main):002:0> SecureRandom.uuid
=> "5087e8b6-ee54-40f9-b592-8c2813c7037d"
```

### Create the model

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/master/app/models/cma_case.rb)

### Create the view template

[CMA cases](https://github.com/alphagov/specialist-publisher/blob/master/app/views/metadata_fields/_cma_cases.html.erb)

## Configure rummager

### Add the schema

Rummager needs a copy of a schema very similar to the one in Specialist Publisher.

See [CMA cases](https://github.com/alphagov/rummager/blob/master/config/schema/elasticsearch_types/cma_case.json).

You also need to
[tell Rummager about the format](https://github.com/alphagov/rummager/blob/master/config/govuk_index/migrated_formats.yaml#L20)
so it will allow it to be indexed.

## Add a schema to govuk-content-schemas

1. Add the format to [this list](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/specialist_document.jsonnet#L2-L22)
2. Add any new field definitions to [this file](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/shared/definitions/_specialist_document.jsonnet)
3. Add examples [as instructed](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/adding-a-new-schema.md#examples)
4. Follow the rest of [the workflow](https://github.com/alphagov/govuk-content-schemas/blob/master/docs/suggested-workflows.md)

## Deploy and publish

Once you're ready to ship your code to an environment,

1. Deploy Specialist Publisher, Rummager, and govuk-content-schemas.
2. Run the "Search reindex for new schema" Jenkins job.  This takes around 45 minutes.
3. Use the "Run rake task" Jenkins job to run `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app on a backend machine.
