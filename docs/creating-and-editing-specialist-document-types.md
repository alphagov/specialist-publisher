# Creating or editing specialist document types

To create or edit a new specialist document you will have to make changes to this
application, [govuk-content-schemas][govuk-content-schemas] and
[search-api][search-api]. You will not have to make any changes to frontend
applications.

[govuk-content-schemas]: https://github.com/alphagov/govuk-content-schemas
[search-api]: https://github.com/alphagov/search-api

# __Creating__ a specialist document type

## 1. Add a schema to govuk-content-schemas

See example [PR for adding `product_safety_alert`](https://github.com/alphagov/govuk-content-schemas/pull/1077).

1. Add the format to [this list](https://github.com/alphagov/govuk-content-schemas/blob/main/formats/specialist_document.jsonnet#L2-L31) and to [this list](https://github.com/alphagov/govuk-content-schemas/blob/main/lib/govuk_content_schemas/allowed_document_types.yml)
2. Add any new field definitions to [this file](https://github.com/alphagov/govuk-content-schemas/blob/main/formats/shared/definitions/_specialist_document.jsonnet)
3. Add examples [as instructed](https://github.com/alphagov/govuk-content-schemas/blob/main/docs/adding-a-new-schema.md#examples).
   You can copy and paste from another specialist document format, only changing what is necessary (you can leave the body and headers unchanged).

You'll need to generate your own UUIDs for the `content_id` and `signup_content_id` fields:

```
$ irb
irb(main):001:0> require "securerandom"
=> true
irb(main):002:0> SecureRandom.uuid
=> "5087e8b6-ee54-40f9-b592-8c2813c7037d"
```
4. Run `bundle exec rake build` to regenerate schemas.

When the PR is reviewed and its tests passing, it can be merged and deployed at this point.

## 2. Create a new specialist document format in Specialist Publisher

### Create the schema

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/lib/documents/schemas/cma_cases.json).

New formats are often requested to be deployed in "pre-production mode", which is configured in this step ([example](https://github.com/alphagov/specialist-publisher/blob/f8e93142dfad6f3971a73c923b01f2e7352bdb54/lib/documents/schemas/tax_tribunal_decisions.json#L64)). `pre-production` documents are only publishable on development and integration.

### Create the model

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/models/cma_case.rb)

### Create the view template

[CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/views/metadata_fields/_cma_cases.html.erb)

## 3. Configure Search API

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

## 4. Configure the email sign up page

The email sign up page is rendered by [Finder Frontend](https://github.com/alphagov/finder-frontend) using the configuration in the new schema added to specialist publisher.

If your email sign up page should have checkboxes (e.g. [cma-cases](https://www.gov.uk/cma-cases/email-signup)), you will need to edit email-alert-api by adding the new tags to [valid_tags.rb](https://github.com/alphagov/email-alert-api/blob/3e0018510ea85f5d561e2865ad149832b94688a1/lib/valid_tags.rb#L2).

## 5. Deploy and publish

To deploy:

1. Deploy Specialist Publisher and Search API (and govuk-content-schemas if you haven't already).
2. [Reindex the govuk Elasticsearch index](https://docs.publishing.service.gov.uk/manual/reindex-elasticsearch.html#how-to-reindex-an-elasticsearch-index).
  - This takes around 30-45 minutes on Production, or 3-4 hours on Integration.
  - NB: reindexing shouldn't really be necessary; Elasticsearch will dynamically create the field mappings the first time a new document of this type is published. In other words, if you publish a new document type, the finder will work and it will return the relevant documents even without a reindex. However, the filters on the finder would not work, as this reindexing job also builds the filters for the finder, so we have to run the job.
3. Use the "Run rake task" Jenkins job to run `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app on a backend machine.

## 6. Permissions

Specialist Publisher grants access to the publishing interface for your new document type to the following Signon users:

- Users that belong to the owner organisation AND have `Editor` permissions
- Users that have the permission `your_new_document_type_editor`, e.g. `oim_project_editor`

You'll need to [create the new permission manually](https://docs.publishing.service.gov.uk/repos/signon/usage.html#creating-new-permissions).

# __Editing__ a specialist document type

We often receive requests to add new fields to a specialist document. Or to add new values to existing fields.

## Adding a new field to an existing specialist document

1. In govuk-content-schemas, add the new field to [the specialist document schema](https://github.com/alphagov/govuk-content-schemas/blob/main/formats/shared/definitions/_specialist_document.jsonnet). See [this](https://github.com/alphagov/govuk-content-schemas/pull/1066/commits/c2b33fbdbdc3ce7363b87e964b8ff75dc3300573#diff-3c69cee80f0f1b0cb114f9f9f102122b33e2208ecf3a77829506390b9938eb61) commit for an example. Once approved, this change can be merged and deployed.

2. In specialist-publisher, add the new field to the relevant [model](https://github.com/alphagov/specialist-publisher/tree/main/app/models), [form](https://github.com/alphagov/specialist-publisher/tree/main/app/views/metadata_fields), and [schema](https://github.com/alphagov/specialist-publisher/tree/main/lib/documents/schemas) files. See [this](https://github.com/alphagov/specialist-publisher/pull/1899/commits/cc9e8fe482dbca2ef678bb8219252e7bd4f4d154) commit for an example.

3. In search-api, add the new field in the following places (see [this](https://github.com/alphagov/search-api/pull/2320/commits/ca6d0142e29b9755aad2e6bd59a3f576b727bd24) commit for an example):
  - the relevant schema in the [elasticsearch_types ](https://github.com/alphagov/search-api/tree/main/config/schema/elasticsearch_types)directory.
  - the [elasticsearch_presenter](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/elasticsearch_presenter.rb).
  - the [specialist_presenter](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/specialist_presenter.rb).
  - the [field_definitions](https://github.com/alphagov/search-api/blob/main/config/schema/field_definitions.json) file.


4. Follow steps in the [Deploy and publish](#Deploy-and-publish) section above, to re-publish the finder and reindex the GOVUK search index.

## Adding or amending values for existing fields on a specialist document

1. In govuk-content-schemas, find the field you are amending in the [specialist_document schema](https://github.com/alphagov/govuk-content-schemas/blob/main/formats/shared/definitions/_specialist_document.jsonnet), and add the new values. See [this](https://github.com/alphagov/govuk-content-schemas/pull/1066/commits/b81ec718f52b1e6603c201c44db07f0357158723) commit for an example. Once approved, this change can be merged and deployed.

2. In specialist-publisher, add the new values to the relevant file in the [schema](https://github.com/alphagov/specialist-publisher/tree/main/lib/documents/schemas) directory. See [this](https://github.com/alphagov/specialist-publisher/pull/1899/commits/97c8d713f8e62b0cb8763fe26e1dcf5a0435c12d) commit for an example.

3. In search-api, amend the value in the relevant schema in the [elasticsearch_types](https://github.com/alphagov/search-api/tree/main/config/schema/elasticsearch_types) directory. See [this](https://github.com/alphagov/search-api/pull/2320/commits/0f29e310581e30707eea7fe8c91063974636dbe2) commit for an example.

4. Republish the finder, see step 3 in the [Deploy and publish](#Deploy-and-publish) section above. You do not need to reindex search :sweat_smile:

# __Editing__ a specialist finder

The [schema](https://github.com/alphagov/specialist-publisher/tree/main/lib/documents/schemas) files that define a specialist document, are also used to configure that document's specialist finder. See [this](https://github.com/alphagov/specialist-publisher/pull/1899/commits/925abc689119138a0e04e17d3610f8ae276773dd) commit for an example.
