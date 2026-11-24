# Bulk unpublishing

Documents can be unpublished in bulk from `/bulk-unpublish`, as an alternative
to the `bulk_unpublish_documents` rake task described in [Rake tasks](./tasks.md).

## Access

The page is only available to users with the `gds_editor` permission, who can
already unpublish any document one at a time through the UI. The navigation
link is hidden from everyone else.

## How it works

1. The user picks a document type and pastes a CSV with a `base_path` and an
   `alternative_path` column.
2. Preview resolves every base path to a document and lists what will happen to
   each one. Nothing is changed at this point.
3. Confirming queues `BulkUnpublishWorker`, which re-checks the permission and
   re-validates the CSV before unpublishing anything.

A row with an `alternative_path` is redirected to that path. A row without one
is marked as gone. This matches unpublishing a single document through the UI.

## Limitations

- Each run covers one document type, because every base path is checked against
  that document type's finder path.
- Only English documents can be unpublished. Use the rake task for any other
  locale.
- There is no report when the run finishes. Progress and any failed rows are
  written to the application logs, and failures are sent to Sentry.
