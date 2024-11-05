# Creating, editing and removing specialist document types and finders

To create or edit a new specialist document you will have to make changes to this
application, [publishing-api][publishing-api] and [search-api][search-api]. You will not have to make any changes to frontend
applications.

[publishing-api]: https://github.com/alphagov/publishing-api
[search-api]: https://github.com/alphagov/search-api

# __Creating__ a specialist document type

<!-- TODO: Update example links in the documentation, to reflect latest documentation. Some of the steps are now no longer needed, but example PRs are outdated since no new requests for changes have been made. Also, remove the notes about not adding enums, once all examples are updated. -->

## 1. Add a schema to Publishing API
See [example PR here](https://github.com/alphagov/publishing-api/pull/2589/files)

1. Add the format to [allowed document types list](https://github.com/alphagov/publishing-api/blob/main/content_schemas/allowed_document_types.yml).
2. Add any new field definitions to [this file](https://github.com/alphagov/publishing-api/blob/main/content_schemas/formats/shared/definitions/_specialist_document.jsonnet).

    **Note**: Do not specify the field values as an enum, as we're moving towards a more relaxed schema definition.
3. Run `bundle exec rake build_schemas` to regenerate schemas.

When the PR is reviewed and its tests passing, it can be merged and deployed at this point.

## 2. Create a new specialist document format in Specialist Publisher

### Create the schema

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/lib/documents/schemas/cma_cases.json).

New formats should be added with `target_stack: "draft"` so that departments can preview the finder before you publish it.

You'll need to generate your own UUIDs for the `content_id` (of the finder), and the `signup_content_id` fields:

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

See [CMA cases](https://github.com/alphagov/specialist-publisher/blob/main/app/views/metadata_fields/_cma_cases.html.erb)

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

The email sign up page is rendered by [Finder Frontend](https://github.com/alphagov/finder-frontend) using the configuration in the new schema added to specialist publisher. The schema should specify `email_filter_by` and `email_filter_facets` (e.g. [cma-cases](https://github.com/alphagov/specialist-publisher/blob/ce68fdb008cab05225e0493e19decba5365e1e20/lib/documents/schemas/cma_cases.json#L29)).

If your email sign up page should have checkboxes (e.g. [cma-cases](https://www.gov.uk/cma-cases/email-signup)), you will need to edit email-alert-api by adding the new tags to [valid_tags.rb](https://github.com/alphagov/email-alert-api/blob/3e0018510ea85f5d561e2865ad149832b94688a1/lib/valid_tags.rb#L2).

## 5. Deploy a finder to the draft stack (for previewing)

To deploy a new finder for previewing:
   1. Ensure the finder target_stack is set to `draft`
   1. Merge and deploy Publishing API, Specialist Publisher and Search API. 
      - Ensure you deploy Publishing API first, to avoid schema validation errors.
      - Also deploy Email Alert API if you have made changes to it.
   1. Run `search:update_schema` in Search API.
   1. Publish the finder to the draft stack by running the rake task `publishing_api:publish_finders` or `publishing_api:publish_finder[pluralised_format_name]` against the specialist publisher app (rake tasks [here](https://github.com/alphagov/specialist-publisher/blob/ce68fdb008cab05225e0493e19decba5365e1e20/lib/tasks/publishing_api.rake)).
   1. Wait for department's feedback and approval and agree on a release date

NB: Depending on the finder requirements, you may choose to allow the users to publish documents in preview mode, which 
would enable them to test the full finder filtering functionality. Changes to the schema requested after documents have been
published, could require running a reindex, and there is a risk of loss of data. In order to prevent users from publishing,
we could give only basic Signon permissions whilst in preview mode. Signon access to the Specialist Publisher app, only 
gives the user writer access (they may create, edit, and update, but not publish or unpublish).

## 6. Publish a finder

To release the finder to the live stack:
   1. Prepare before the agreed release date. Merge PRs and release on agreed date.
   1. Merge and deploy Search API
   1. [Reindex the govuk Elasticsearch index](https://docs.publishing.service.gov.uk/manual/reindex-elasticsearch.html#how-to-reindex-an-elasticsearch-index).
       - This takes around 30-45 minutes on Production, or 3-4 hours on Integration.
       - Alternatively, run `search:update_schema` for a shorter run. Make sure the this is run before any documents are published, otherwise a full reindex will be required.
      
      **Note**: reindexing shouldn't really be necessary; Elasticsearch will dynamically create the field mappings the first time a new document of this type is published. In other words, if you publish a new document type, the finder will work and it will return the relevant documents even without a reindex. However, **the filters on the finder would not work**, as this reindexing job also builds the filters for the finder, so we have to run the job.
   1. Change the target_stack of the finder from `draft` to `live` in specialist-publisher json schema config
   1. Merge and deploy Specialist Publisher
   1. Publish the finder by running the rake task `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app (rake tasks [here](https://github.com/alphagov/specialist-publisher/blob/ce68fdb008cab05225e0493e19decba5365e1e20/lib/tasks/publishing_api.rake)).
 
## 7. Permissions

Specialist Publisher grants access to the publishing interface for your new document type to the following Signon users:

- Users that belong to the owner organisation AND have `Editor` permissions
- Users that have the permission `your_new_document_type_editor`, e.g. `oim_project_editor`

You'll need to [create the new permission manually](https://docs.publishing.service.gov.uk/repos/signon/usage.html#creating-new-permissions).

# __Editing__ a specialist document type

We often receive requests to add new fields to a specialist document or to add new values to existing fields.

## Adding a new field to an existing specialist document

1. In `publishing-api`:
   - Add the new field in the [specialist_document schema](https://github.com/alphagov/publishing-api/blob/6d5595470bd0e7f3072e06f0113e3ca5514b6e98/content_schemas/formats/shared/definitions/_specialist_document.jsonnet). See [example commit](https://github.com/alphagov/publishing-api/pull/2479/files#diff-e427ec772dc2597718b907f2db7772ad580d90452a76ce291114ddd0cfacb289).

  **NOTE**: You will need to run `bundle exec rake build_schemas` to regenerate schemas after adding the new value(s). Do **not** specify the field values as an enum, as we're moving towards a more relaxed schema definition.

2. In `specialist publisher`:
   - Add the new field to the relevant [model](https://github.com/alphagov/specialist-publisher/tree/main/app/models).
   - Add field to relevant [view](https://github.com/alphagov/specialist-publisher/tree/main/app/views/metadata_fields).
   - Add fields to relevant [schema](https://github.com/alphagov/specialist-publisher/tree/main/lib/documents/schemas) files. 
   
<!-- TODO: Update these with up-to-date examples -->
   See [this](https://github.com/alphagov/specialist-publisher/pull/1899/commits/cc9e8fe482dbca2ef678bb8219252e7bd4f4d154) commit for an example.

3. In `search-api`, add the new field in the following places (see [this](https://github.com/alphagov/search-api/pull/2320/commits/ca6d0142e29b9755aad2e6bd59a3f576b727bd24) commit for an example):
   - the relevant schema in the [elasticsearch_types ](https://github.com/alphagov/search-api/tree/main/config/schema/elasticsearch_types)directory.
   - the [elasticsearch_presenter](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/elasticsearch_presenter.rb).
   - the [specialist_presenter](https://github.com/alphagov/search-api/blob/main/lib/govuk_index/presenters/specialist_presenter.rb).
   - the [field_definitions](https://github.com/alphagov/search-api/blob/main/config/schema/field_definitions.json) file.

To republish the finder:
1. Deploy Publishing API, Search API.
1. Run `search:update_schema` on Search API. If this errors, you may have to do a [full reindex](https://docs.publishing.service.gov.uk/manual/reindex-elasticsearch.html#how-to-reindex-an-elasticsearch-index).
1. Deploy Specialist Publisher, deploy after the Search API schema update / reindex to avoid users publishing new documents with the new field.
1. Publish the finder by running the rake task `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app (rake tasks [here](https://github.com/alphagov/specialist-publisher/blob/ce68fdb008cab05225e0493e19decba5365e1e20/lib/tasks/publishing_api.rake)).

## Adding values for existing fields on a specialist document
1. In `specialist publisher`, add the new values to the relevant file in the [schema](https://github.com/alphagov/specialist-publisher/tree/main/lib/documents/schemas) directory. See [this](https://github.com/alphagov/specialist-publisher/pull/1899/commits/97c8d713f8e62b0cb8763fe26e1dcf5a0435c12d) commit for an example.

2. In `search-api`, amend the value in the relevant schema in the [elasticsearch_types](https://github.com/alphagov/search-api/tree/main/config/schema/elasticsearch_types) directory. See [this](https://github.com/alphagov/search-api/pull/2320/commits/0f29e310581e30707eea7fe8c91063974636dbe2) commit for an example.

To republish the finder:
1. Deploy Publishing API, Search API, Deploy Specialist Publisher.
1. Publish the finder by running the rake task `publishing_api:publish_finders` or `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]` against the specialist publisher app (rake tasks [here](https://github.com/alphagov/specialist-publisher/blob/ce68fdb008cab05225e0493e19decba5365e1e20/lib/tasks/publishing_api.rake)).

# __Editing__ a specialist finder

The [schema](https://github.com/alphagov/specialist-publisher/tree/main/lib/documents/schemas) files that define a specialist document, are also used to configure that document's specialist finder. See [this](https://github.com/alphagov/specialist-publisher/pull/1899/commits/925abc689119138a0e04e17d3610f8ae276773dd) commit for an example.

# __Unpublishing__ a specialist finder

**Important**: In order to remove a finder, you should ensure there is a clear business requirement in doing so, and that all associated documents have been correctly dealt with - unpublished, redirected, migrated or removed.
If the code is not removed from all relevant repositories, there is a chance the finder will be inadvertently republished, for example by republishing all finders. You must therefore make sure the code is removed in order to keep the finder unpublished.

The following steps are required to remove a finder:
1. Unpublish the finder in all environments using the provided rake task:
   ```
   rake unpublish:redirect_finder["uk_market_conformity_assessment_bodies","https://redirection_link.gov.uk"]
   ```
2. Remove usages from `publishing-api`:
   - Remove the format from [allowed document types list](https://github.com/alphagov/publishing-api/blob/main/content_schemas/allowed_document_types.yml).
   - Remove the field definitions from [this file](https://github.com/alphagov/publishing-api/blob/main/content_schemas/formats/shared/definitions/_specialist_document.jsonnet).
   - If present, remove the example from [this directory](https://github.com/alphagov/publishing-api/tree/main/content_schemas/examples/specialist_document/frontend).
   - Run `bundle exec rake build_schemas` to regenerate schemas.
   
   See [example commit](https://github.com/alphagov/publishing-api/pull/2706).

3. Remove usages from `specialist publisher`. See [example commit](https://github.com/alphagov/specialist-publisher/pull/2588/files).
4. Remove usages from `search-api`. See [example commit](https://github.com/alphagov/search-api/pull/2881/files).
5. Remove any usages from `finder-frontend`, if applicable.
6. Deploy all changes.
