## Phase 2 Migration

This directory contains notes for how Specialist Publisher has migrated to the
new Publishing Platform. It is the first app to complete a "phase 2" migration,
which means the [Publishing API](https://github.com/alphagov/publishing-api) is
used for managing its workflow as well as storing the application's content.
Hopefully this will be useful to others who are looking to migrate.

## Sections

1. [Setting the scene](./setting-the-scene.md) – some background information
   about this app and the rewrite
2. [Workflow of content](./workflow-of-content.md) – a diagram and explanation
   of the different workflows for content
3. [Update types](./update-types.md) - an overview of how update types and email
   notifications work
4. [Composed states](./composed-states.md) – an explanation of how 'published
   with new draft' works
5. [Timestamps](./timestamps.md) - an explanation of what each of the timestamps
   are and how they're used
6. [Republishing](./republishing.md) - there are two different types of
   republishing, explained here
7. [Roll-out process](./roll-out-process.md) - how we've rolled out formats one
   at a time to manage risk
8. [Deployment guide](./deployment-guide.md) - a detailed walkthrough for how
   to deploy a new format to production
9. [Automated tests](./automated-tests.md) - an explanation of how we've tested
   the app and a few gotchas
10. [Quality assurance](./quality-assurance.md) - an overview of our QA process
    and why we've taken this approach
