# Specialist Publisher naming conventions

The files typically required to create a finder follow these conventions. Exceptions to these rules require test customization in the codebase, and should be avoided.

## Schema
- Use the pluralised name of the document type, e.g. `cma_cases.json`.
- Within the schema, the `filter.format` is typically set to the singularised name of the document type, e.g. `cma_case`, although it does not have to be. This is used in Search API. It must not be changed once set.

## Model
- The singular name of the document type, e.g. `cma_case.rb`.
- The model name dictates the `document_type` that gets sent to Publishing API. It must not be changed once set.

## View
- Pluralised name of the document type, e.g. `_cma_cases.html.erb`.

## Downstream

### Publishing API

- The [`allowed_document_types.yml`][allowed_document_types.yml] must register the `document_type`, i.e. typically the singular underscore name of the corresponding Specialist Publisher model, e.g. `cma_case`.
- The [`_specialist_document.jsonnet`][_specialist_document.jsonnet] uses a `anyOf` syntax to select one of the registered metadata definitions. We typically use the `<filter.format>_metadata` name for these. 

### Search API
- The [`mapped_document_types.yaml`][mapped_document_types] stores the associations between Publishing API document types and Search API formats (i.e. the `filter.format`).
- [`govuk.json`][govuk.json], [`migrated_formats.yaml`][migrated_formats.yaml] must register the `filter.format`.
- The json file in the [`elasticsearch_types`][elasticsearch_types] directory must use the `filter.format` as file name, e.g. `cma_case.json`.


## Known outliers
- ESI fund. The internal Specialist Publisher convention is `esi_fund(s)`, meaning the `document_type` is `esi_fund`; nonetheless, the [filter format used in Search API](https://github.com/alphagov/search-api/blob/fea45f195b48a31cf48f09ddf2bced9ccc390752/config/govuk_index/mapped_document_types.yaml#L41) is `european_structural_investment_fund`.


[mapped_document_types]: https://github.com/alphagov/search-api/blob/fea45f195b48a31cf48f09ddf2bced9ccc390752/config/govuk_index/mapped_document_types.yaml
[govuk.json]: https://github.com/alphagov/search-api/blob/main/config/schema/indexes/govuk.json
[migrated_formats.yaml]: https://github.com/alphagov/search-api/blob/main/config/govuk_index/migrated_formats.yaml
[elasticsearch_types]: https://github.com/alphagov/search-api/tree/main/config/schema/elasticsearch_types
[allowed_document_types.yml]: https://github.com/alphagov/publishing-api/blob/main/content_schemas/allowed_document_types.yml
[_specialist_document.jsonnet]: https://github.com/alphagov/publishing-api/blob/main/content_schemas/formats/shared/definitions/_specialist_document.jsonnet