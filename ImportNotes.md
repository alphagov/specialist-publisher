# Import Notes

## Project Structure

* `app/models` contains objects that represent "things"
* `app/services` contains command objects that perform actions eg "CreateDocument"
* `app/importers` Import related code lives here.

`DocumentImport` contains generic code for running an import. Format
specific code will live in a namespace under `app/importers/aaib_reports` for example.

## AAIB/MAIB/RAIB/MHRA import code

### DependencyContainer

Instantiates all the concrete objects and introduces objects to their
dependencies.

`#get_instance` provides a configured instance of `BulkImporter` which iterates
through the import data and executes individual import tasks.

Provides the file reader / parser function which it maps a file path glob over.

### Mappers

There are two mappers for converting data between the arbitrary imported data
and the data format we expect. This is the place to map categories or wrangle
text.

Body text must conform to the GOV.UK [Styleguide](https://www.gov.uk/design-principles/style-guide)

Mappers are stacked one on top of another to provide a chain of single-responsibility
objects which perform their task on the data and call down the stack.

At the bottom of the stack will be a "service object" which actually creates a
document.

## Installation for importer development

### Other repository dependencies

* [asset-manager](https://github.com/alphagov/asset-manager)
* development
* [fact-cave](https://github.com/alphagov/fact-cave)
* [finder-api](https://github.com/alphagov/finder-api)
* [imminence](https://github.com/alphagov/imminence)
* puppet
* [rummager](https://github.com/alphagov/rummager)
* [specialist-frontend](https://github.com/alphagov/specialist-frontend)
* [static](https://github.com/alphagov/static)

### VM /etc/hosts file

```
10.1.1.254      specialist-publisher.dev.gov.uk
10.1.1.254      specialist-frontend.dev.gov.uk
10.1.1.254      static.dev.gov.uk
10.1.1.254      contentapi.dev.gov.uk
10.1.1.254      rummager.dev.gov.uk
10.1.1.254      www.dev.gov.uk
10.1.1.254      assets-origin.dev.gov.uk
10.1.1.254      dev.gov.uk
```

## Importing documents

Example: import AAIB reports.

Place the report content in some convenient location, e.g.:

```
~/aaib_content/metadata
~/aaib_content/downloads
```

Then,

```
$ ./import_aaib_reports ~/aaib_content/metadata/ ~/aaib_content/
```
will begin importing the reports as draft.

## Running specialist-publisher

The `development` repository lets you run:

```
$ bowl specialist-publisher specialist-frontend
```

This starts the necessary dependencies too. If some of them are already
running, this may fail. To fix, kill the already running processes.

## Publishing documents

### Publish an imported document

Visit `specialist-publisher.dev.gov.uk`. Click a draft publication
and then press the "Publish" button.

### Publish all imported documents

Start `specialist-publisher`, then run a publish script in `bin`, e.g.

```
$ ./publish_aaib_reports
```

### Republishing documents

Run `specialist-publisher/lib/document_republisher.rb`.

Can specify the type of report to republish, e.g. CMA, AAIB.

For instance, `document_republisher.rb aaib_reports`

### Clearing out documents entirely

A rake task that does:

```
Artefact.destroy_all
SpecialistDocumentEdition.destroy_all
```

will clear out all documents.
