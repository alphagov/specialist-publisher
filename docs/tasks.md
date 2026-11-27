# Rake tasks

## Discarding a draft document

If a document has been created in draft, it can be discarded with this task:
`ops:discard['some-content-id']`

Drafts can also be discarded by running a similar task from the Publishing API:

`discard_draft['some-content-id']`

See [Admin Tasks](https://github.com/alphagov/publishing-api/blob/main/docs/admin-tasks.md)

## Triggering an email notification

If an email has not been sent for a document, it can be re-triggered with this task:
`ops:email['some-content-id']`

## Setting the public_updated_at

If a document has an incorrect public_updated_at, it can be set with this task:
`ops:set_public_updated_at['some-content-id','2016-01-01']`

This is useful if a published document is appearing with an incorrect published time on GOV.UK. This is not something users of the publishing app can set manually and so occasionally we get support requests to change this.

Rails will call `DateTime.parse` on the string provided, so most formats should work. You can also pass ‘now’ to use the current time.

You can’t currently set the `public_updated_at` field if a publisher has created a new draft for the document. You’ll either need to discard it or publish it first for this task to succeed.

## Republishing

Republishing is useful if content failed to make its way through the system. This might be the case if an error was thrown somewhere along the way. Republishing a document will notify Publishing API of the change (which will in turn notify RUMMAGER via a notifaction queue). It will not send email notifications.

You can republish a single document with this task:
`republish:one['some-content-id']`

You can republish all documents for a document_type with this task:
`republish:document_type['some_document_type']`

You can republish all specialist documents with this task:
`republish:all`

These last two tasks place a large number of items on Specialist Publisher’s sidekiq queue. These tasks could take a very long time to complete. You can’t currently republish published documents if a publisher has created a new draft for the document.
