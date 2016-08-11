# Specialist publisher

## Purpose

Publishing App for Specialist Documents and Manuals.

## Nomenclature

* Specialist Documents: Documents with metadata which are published to Finders
* Schema: JSON file defining slug, document noun and name of Specialist Document document_types. Also has select facets and their possible values for each document_type which are displayed by the `_form.html.erb`.
* Manual: Grouped Documents published as a number of sections inside a parent document

## Current formats

### Live

* [AAIB Reports](https://www.gov.uk/aaib-reports)
* [CMA Cases](https://www.gov.uk/cma-cases)
* [Countryside Stewardship Grants](https://www.gov.uk/countryside-stewardship-grants)
* [International Development Funds](https://www.gov.uk/international-development-funding)
* [Drug Safety Update](https://www.gov.uk/drug-safety-updates)
* [ESI Funds](https://www.gov.uk/esi-funds)
* [Medical Safety Alerts](https://www.gov.uk/drug-device-alerts)
* [MAIB Reports](https://www.gov.uk/maib-reports)
* [RAIB Reports](https://www.gov.uk/raib-reports)
* Manuals (there's no public index page for Manuals, they can all be found at `gov.uk/guidance/:manual-slug`)

### Live (but flagged as pre-production)
* [UTAAC Decisions](https://www.gov.uk/utaac-decisions)

## Dependencies

* [alphagov/static](http://github.com/alphagov/static): provides static assets (JS/CSS)
* [alphagov/asset-manager](http://github.com/alphagov/asset-manager): provides uploading for static files
* [alphagov/rummager](http://github.com/alphagov/rummager): allows documents to be indexed for searching in both Finders and site search
* [alphagov/publishing-api](http://github.com/alphagov/publishing-api): allows documents to be published to the Publishing queue
* [alphagov/email-alert-api](http://github.com/alphagov/email-alert-api): sends emails to subscribed users when documents are published

## Running the application

```
$ ./startup.sh
```
If you are using the GDS development virtual machine then the application will be available on the host at https://specialist-publisher-rebuild.dev.gov.uk/

## Granting Permissions

You may find that you can't see any documents after replicating data. To fix
this, you need to grant user permissions in this application:

```bash
bundle exec rake permissions:grant['Chris Patuzzo'] # Or whichever user you're logged in as.
```

You also need to set the `app_name` for the Dummy API User in Publishing API:

```ruby
User.find_by(email: "dummyapiuser@domain.com").update!(app_name: "specialist-publisher")
```

### Populate development database

If you're starting from a blank database, you can quickly get your local database into working order with `$ bundle exec rake db:seed`.

Currently this:
* creates a default user record with basic permissions that allows you to log in and create a new document

## Running the test suite

```
$ bundle exec rake
```

## Adding a new specialist document format

1. Create a model which inherits from `Document` within: `specialist-publisher/app/models`

  - Structure of this model will be very similar to those of other format models. See `aaib_report.rb` for an example of what the model for this new format will need to include (i.e validations, `FORMAT_SPECIFIC_FIELDS`)

1. Add the format definition to the `data` hash in `ApplicationController`. This ensures that the file naming convention of `specialist-publisher` will work for the new format

1. Create a schema within: `specialist-publisher/lib/documents/schemas`

1. Add metadata form fields within: `specialist-publisher/app/views/metadata_fields`

 - Ensure labels and form fields are wrapped in bootstrap `form-group` classes

1. Add model spec within: `spec/models`

## Deployment

Currently, this app is deployed along side with [Specialist-publisher v1](https://github.com/alphagov/specialist-publisher) on a "per-format" basis. As more formats become production ready, we will transition them to use the rebuild app.

![deployment diagram](deployment.png)

The rebuild app can then be accessed in two ways.

1. At the URL `specialist-publisher.*.gov.uk`: you can access the "Frankenstein" app, a combination between SPv1 + SPv2.

2. At `specialist-publisher-rebuild-standalone.integration.publishing.service.gov.uk`: This is an integration-only instance of the app running only specialist-publisher-rebuild code.

When a format is ready to deploy to production, add the endpoint to this [puppet configuration](https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk/manifests/node/s_backend_lb.pp#L48). This will configure Nginx to route requests for those endpoints to be handled by this app.
