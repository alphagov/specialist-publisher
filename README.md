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
* [International Development Funds](https://www.gov.uk/international-development-funds)
* [Drug Safety Update](https://www.gov.uk/drug-safety-updates)
* [ESI Funds](https://www.gov.uk/esi-funds)
* [Medical Safety Alerts](https://www.gov.uk/drug-device-alerts)
* [MAIB Reports](https://www.gov.uk/maib-reports)
* [RAIB Reports](https://www.gov.uk/raib-reports)
* Manuals (there's no public index page for Manuals, they can all be found at `gov.uk/guidance/:manual-slug`)

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

### Populate development database

In order to quickly get your local database into working order run `$ bundle exec rake db:seed`.

Currently this:
* creates a default user record with basic permissions that allows you to log in and create a new document

### Notes on Mock User while running the application on development environment

In the development environment, a mock user is created automatically by the gds-sso gem.
The creation of this mock api user requires a User instance in the application.

This can be done by the following steps (if using a development VM):

1. In the project directory, run `bundle exec rails console`
2. In the Rails console, run `User.create`. This creates an empty user instance that is sufficient for the gds-sso gem to work.

Secondly, this app relies on publishing-api for all its document data, which are filtered by `app_name` attribute on the API user on publishing-api.
If you experience a problem where you know there should be documents in your local copy of publishing-api but nothing is displayed when running the application.
Check that the development api user (created automatically by gds-sso gem) has the `app_name` correctly set to `"specialist-publisher"`

This can be done by the following steps (if using a development VM):

1. Go to the publishing-api directory in your VM and run `bundle exec rails console`
2. Find and update the dummy api user by running `User.find_by(email: "dummyapiuser@domain.com").update(app_name: "specialist-publisher")`

Now your application should be able to retrieve specialist documents from publishing-api

## Running the test suite

```
$ bundle exec rake
```

## Adding a new specialist document format

1. Create a model which inherits from `Document` within: `specialist-publisher/app/models`

  - Structure of this model will be very similar to those of other format models. See `aaib_report.rb` for an example of what the model for this new format will need to include (i.e validations, `FORMAT_SPECIFIC_FIELDS` and the `publishing_api_document_type`)

1. Add the format definition to the `data` hash in `ApplicationController`. This ensures that the file naming convention of `specialist-publisher` will work for the new format

1. Create a schema within: `specialist-publisher/lib/documents/schemas`

1. Add metadata form fields within: `specialist-publisher/app/views/metadata_fields`

 - Ensure labels and form fields are wrapped in bootstrap `form-group` classes

1. Add model spec within: `spec/models`

### Testing your new specialist document format

####TODO

## Application Structure

####TODO

### Directory Structure

Non standard Rails directories and what they're used for:

####TODO


### Services

####TODO
