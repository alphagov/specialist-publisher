# Import Notes

## Project Structure

* app/models contains objects that represent "things"
* app/services contains command objects that perform actions eg "CreateDocument"
* app/importers Import related code lives here.

DocumentImport contains generic code for running an import. Format
specific code will live in a namespace under app/importers/aaib_reports for example.

## Entry point

There is an executable Ruby script in the bin directory for each format specific
import.

### AAIB Import code

#### DependencyContainer

Instantiates all the concrete objects and introduces objects to their
dependencies.

`#get_instance` provides a configured instance of BulkImporter which iterates
through the import data and executes individual import tasks.

Provides the file reader / parser function which it maps a file path glob over.

#### Mappers

There are two mappers for converting data between the arbitrary imported data
and the data format we expect. This is the place to map categories or wrangle
text.

Body text must conform to the GOVUK [Styleguide](https://www.gov.uk/design-principles/style-guide)

Mappers are stacked one on top of another to provide a chain of single-responsibility
objects which perform their task on the data and call down the stack.

At the bottom of the stack will be a "service object" which actually creates a
document.
