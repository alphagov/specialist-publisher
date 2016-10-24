## Republishing

Republishing is the act of reading content out of one system and writing it into
the Publishing API. There are two main reasons to republish:

- To import content in the Publishing API for the first time
- To add/remove fields from content or fix data in the Publishing API

## Republishing for the first time

We wrote a rake task in the old Specialist Publisher that reads content out of
Mongo and writes it into the Publishing API. We check what state the content is
in and issue a set of requests to transition the content into that state in
Publishing API.

We were very careful around unpublished content. We felt that it was dangerous
to transition content through the 'published' state to get to 'unpublished'. To
avoid this, we asked the Publishing Platform team to add an 'allow_draft' flag
to the /unpublish endpoint that allows draft content to be directly transitioned
to unpublished.

## Republishing to add/remove fields

During the development of Specialist Publisher, we realised we'd need a process
for making sweeping changes to content to add/remove fields or make other
structural/data changes. For example, we added some
[timestamps](./timestamps.md) later on in the development of the rebuild.

To accommodate this need, we wrote a
[republish rake task](https://github.com/alphagov/specialist-publisher-rebuild/blob/39745ac21b8717130cb3d210469b06cfb2ea72ca/lib/tasks/republish.rake) that reads all content from the Publishing API, runs it through
the application's presenters and writes it back again. At present, this doesn't
cater for content that is published/unpublished but has a new draft, but
[that](https://trello.com/c/SpsOfLQW/201-spike-republishing-documents-that-have-both-a-published-unpublished-document-and-a-draft)
is on the list of things to fix.
