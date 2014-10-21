[![Code Climate](https://codeclimate.com/github/alphagov/specialist-publisher.png)](https://codeclimate.com/github/alphagov/specialist-publisher)

# Specialist publisher

## Purpose

Publishing App for Specialist Documents and Manuals.

## Nomenclature

* Specialist Documents: Documents with metadata which are published to Finders
* Manual: Grouped Documents published as a number of sections inside a parent document

## Current formats

### Live
* [CMA Cases](https://www.gov.uk/cma-cases)
* [International Funding Development](https://www.gov.uk/international-funding-development)
* Manuals (there's no public index page for Manuals, they can all be found at `gov.uk/guidance/:manual-slug`)

### Live with no content
* AAIB Reports
* Drug Safety Updates
* Medical Safety Alerts

## Dependancies

[alphagov/static](http://github.com/alphagov/static): provides static assets (JS/CSS)
[alphagov/panopticon](http://github.com/alphagov/panopticon): provides public URLs for content on GOV.UK
[alphagov/asset_manager](http://github.com/alphagov/asset_manager): provides uploading for static files
[alphagov/rummager](http://github.com/alphagov/rummager): allows documents to be indexed for searching in both Finders and site search
[alphagov/publishing-api](http://github.com/alphagov/publishing-api): allows documents to be published to the Publishing queue

## Running the application

```
$ ./startup.sh
```
If you are using the GDS development virtual machine then the application will be available on the host at http://specialist-publisher.dev.gov.uk/

## Running the test suite

```
$ bundle exec rake
```

## Adding a new specialist document format

Still to come...

## Application Structure

### Directory Structure

Non standard Rails directories and what they're used for:

* `app/exporters`
  These export information to various GOV.UK APIs
  * `app/exporters/formatters`
    These are used by exporters to format information for transferring as JSON
* `app/importers`
  Generic code used when writing importers for scraped content of new document formats
* `app/models`
  Combination of Mongoid documents and Ruby objects for handling Documents and various behaviours
  * `app/models/builders`
    Ruby objects for building a new document by setting ID and subclasses for setting the document type, if needed
  * `app/models/validators`
    Not validators. Decorators for providing validation logic.
* `app/observers`
  Define ordered lists of exporters, called at different stages of a documents life cycle, for example, publication.
* `app/repositories`
  Provide interaction with the persistance layer (Mongoid)
* `app/services`
  Reusable classes for completing actions on documents
* `app/view_adapters`
  Provide classes which allow us to have Rails like form objects in views
* `app/workers`
  Classes for sidekiq workers. Currently the only worker in the App is for publishing Manuals as Manual publishing was timing out due to the large number of document objects inside a Manual


### Wiring

### Services

 Services do things such as previewing a document, creation, updating, showing, withdrawing, queueing. This replaces the normal Rails behaviour of completeing these actions directly from a controller, instead we call a service registry

### Document structure
