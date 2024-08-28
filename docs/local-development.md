# Local Development

## Testing finders end-to-end locally

See the [GOV.UK Docker documentation](https://docs.publishing.service.gov.uk/repos/govuk-docker/how-tos/finder-setup.html).

## Search API configuration changes

When you make changes to the Search API configuration, you will need to migrate to the new schema.

```bash
govuk-docker exec search-api-app env SEARCH_INDEX=govuk bundle exec rake search:migrate_schema
```

Note that you may need to republish documents to see changes to the schema reflected in the search results after migrating.