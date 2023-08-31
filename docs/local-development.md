# Local Development

It is possible to test changes to specialist finders end-to-end using the govuk docker stack. This is useful to avoid having to reindex all of the content on integration to test changes. Here's how to do it:

1. Start the specialist publisher and finder frontend services. They will spin up all necessary dependencies.

```bash
govuk-docker up specialist-publisher-app -d
govuk-docker up finder-frontend -d
```

2. Create the search indices

```bash
govuk-docker exec search-api-app env SEARCH_INDEX=all bundle exec rake search:create_all_indices
```

3. Create the RabbitMQ exchange for Publishing API to send messages to

```bash
govuk-docker exec publishing-api-app bundle exec rake setup_exchange
```

4. Create the Search API message queues

```bash
govuk-docker exec search-api-app bundle exec rake message_queue:create_queues
```

5. Publish the routes for the Search API endpoints

```bash
govuk-docker exec search-api-app bundle exec rake publishing_api:publish_special_routes
```

6. Publish your finder, for example

```bash
govuk-docker exec specialist-publisher-app bundle exec rails publishing_api:publish_finder\[ai_assurance_portfolio_techniques\] 
```

7. Run the Search API queue consumer. You need to keep this process running to index published documents.

```bash
govuk-docker exec search-api-worker bundle exec rake message_queue:insert_data_into_govuk
```

When you publish a specialist document, it should be updated in the search results.

Note that elasticsearch data is not persisted when you stop the docker container at present.

## Search API configuration changes

When you make changes to the Search API configuration, you will need to migrate to the new schema.

```bash
govuk-docker exec search-api-app env SEARCH_INDEX=govuk bundle exec rake search:migrate_schema
```

Note that you may need to republish documents to see changes to the schema reflected in the search results after migrating.