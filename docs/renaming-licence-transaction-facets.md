# Renaming Licence Transaction Facets

Renaming licence transaction industry facets needs to occur in 2 parts. 
First, the schema needs to be updated with the new/renamed industry facet names and values, and second the licence transactions tagged to the old facets will need to be re-tagged.

This process is temporary and is designed to update the existing industry names from [Licence Finder](https://www.gov.uk/licence-finder/licences-api).

It might be possible to get the current values in the schema and update those instead. However it would still be a mostly manual process as the schema definition needs to be updated in the codebase.

## Update the licence transaction schema

1. Check out a new branch of Specialist Publisher
2. Update the [CSV file](lib/data/licence_transaction/industry_sectors_new_values.csv). The CSV is pipe delimited.
3. Run `bundle exec rake licence_transaction:rename_industry_sectors:update_schema` locally
4. Commit the updated schema file
5. Create a PR and get it merged

## Re-tag licence transactions

1. Make sure the [schema](lib/documents/schemas/licence_transactions.json) has been updated as expected.
2.  Access an environment by either [ssh-ing on to a machine](https://docs.publishing.service.gov.uk/manual/howto-ssh-to-machines.html) or via [jenkins](https://docs.publishing.service.gov.uk/manual/access-jenkins.html) (Correct at time of writing).
3. Run `bundle exec rake licence_transaction:rename_industry_sectors:retag_licence_transactions`
