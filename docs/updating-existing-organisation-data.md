# Updating existing organisation data

Departments will sometimes ask for functional data for particular specialist publisher organisation to be updated. Examples of this include adding or updating a new sub-category or specifying the content id of the organisation so that it will be applied to the associated finder page.

This data can be found in `lib/documents/schemas`. These schemas follow the same format and are fairly self explanatory in relation to what needs to be updated. Check the apps which render the content for specialist publisher ([finder-frontend](https://github.com/alphagov/finder-frontend) and [frontend](https://github.com/alphagov/frontend)) and the specialist publisher code itself for more details about how a particular piece of data is used or presented.

## Updating an organisation's finder page

A finder page acts as a homepage for a particular specialist document set. [Example of a finder for AAT decisions](https://www.gov.uk/administrative-appeals-tribunal-decisions). If you are making a change that impacts this page, you will need to run the `publish_finders` rake task following deployment to re-publish any altered finders:

- [Integration](https://deploy.integration.publishing.service.gov.uk/job/run-rake-task/parambuild/?TARGET_APPLICATION=specialist-publisher&MACHINE_CLASS=backend&RAKE_TASK=publishing_api:publish_finders)
- [Staging](https://deploy.blue.staging.govuk.digital/job/run-rake-task/parambuild/?TARGET_APPLICATION=specialist-publisher&MACHINE_CLASS=backend&RAKE_TASK=publishing_api:publish_finders)
- [⚠️ Production ⚠️](https://deploy.blue.production.govuk.digital/job/run-rake-task/parambuild/?TARGET_APPLICATION=specialist-publisher&MACHINE_CLASS=backend&RAKE_TASK=publishing_api:publish_finders)