# Email alerts & "Latest from" updates

The Specialist Publisher app is a special case in terms of email alerts, similar to the Travel Advice Publisher. They are both [excluded](https://github.com/alphagov/email-alert-service/blob/main/email_alert_service/models/major_change_message_processor.rb#L87) from the typical alerts flow, allowing a more specialised email subscription approach. A specialist finder allows a user to subscribe to its documents. Alerts can be received daily, weekly or on page update. There are various [subscription options](./creating-editing-and-removing-specialist-document-types-and-finders.md#4-configure-the-email-sign-up-page), generic or facet-based.

This documentation will focus on observed behaviours, but here are a few key technical aspects identified so far:
- The finder page and the documents under it have the `publishing_app` set to `specialist-publisher`, so both document types are excluded from the typical email alerts flow.
- We send [alerts](https://github.com/alphagov/specialist-publisher/blob/main/app/services/document_publisher.rb#L20) for the documents themselves, directly to `email-alert-api`, sidestepping [publishing API's RabbitMQ](https://github.com/alphagov/publishing-api/blob/main/docs/rabbitmq.md).
- The subscription page (rendered by `email-alert-frontend`) uses a query parameter `/email/subscriptions/new?topic_id=marine-notices` to identify the subscription list.
- The finder page is sent to Publishing API with the `update_type` always set to "minor", though this seems redundant if all the updates are blocked via the exclusion in the email alert service.
- Because there is no custom alert logic for the finder item, as there is for the documents, updates to the finder page itself do not trigger alerts. Whilst it's hard to confirm this was historically intentional, it generally suits the user needs, as custom comms related to finder go-live tend to cover this aspect. Other document types such as news articles might be published to support the go-live, also causing email alerts to be sent to organisation subscribers.
- The "Latest from" section is available on organisation pages and shows the latest updates to content that is considered under the organisation. It feeds from Search API, and we have no control over what is shown there.

What email alerts are sent to users subscribed to the finder or its organisation is a requirement that becomes particularly relevant when we first launch a finder. Due to a variety of reasons, departments may not want to allow alerts, or would prefer to not show all the document updates in the organisation's "Latest from" section. It is important that we understand what is possible in our systems. The following tables summarise the behaviour of email alerts and "Latest from" entries for different publishing actions, depending on the user's subscription status.

An explanatory note for the tables below:
- An organisation "prefix" on the email alert would read as: "You asked GOV.UK to send you an email each time we add or update a page about: \n Maritime and Coastguard Agency". In the table it means that the user gets notified by virtue of them being subscribed to the organisation.
- A finder "prefix" on the email alert would read as: "You asked GOV.UK to send you an email each time we add or update a page about: \n Marine notices". In the table it means that the user gets notified by virtue of them being subscribed to the finder.
- The ["silent" rake task](https://github.com/alphagov/specialist-publisher/blob/4bcd9d1e99975e09c1c942d7bcf6233b03f26af0/lib/tasks/publish.rake#L18) was introduced with the purpose of avoiding sending email alerts for documents, particularly when launching a finder with numerous documents. It is also used for periodically publishing documents in bulk for some finders. 
- The finder developer rake task refers to `publishing_api:publish_finder[your_format_name_based_on_the_schema_file]`, used to publish the finder for the first time, and for all subsequent updates.
- The approach taken to extract the behaviours was to test the publishing actions in integration, with the different subscription states. Followed the [developer docs on how to test email alerts](https://docs.publishing.service.gov.uk/repos/email-alert-api/receiving-emails-from-email-alert-api-in-integration-and-staging.html#content).

## 1. When user is subscribed to the organisation

Note that no email alerts are sent on finder publication.

| Action                                                           | Sends email with organisation prefix | Shows in the "Latest from" on the organisation page          |
|------------------------------------------------------------------|--------------------------------------|--------------------------------------------------------------|
| Publish finder via developer rake task                           | No                                   | Yes, new entry                                               |
| Publish subsequent updates to the finder via developer rake task | No                                   | Not as a new entry (old entry updated)                       |
| Publish a first draft specialist document via UI                 | Yes                                  | Yes, new entry                                               |
| Publish first draft documents via silent rake task               | No                                   | Yes, new entry                                               |
| Publish a major change draft specialist document via UI          | Yes                                  | Not as a new entry (old entry updated and bumped to the top) |
| Publish a major change specialist documents via silent rake task | No                                   | Not as a new entry (old entry updated and bumped to the top) |
| Publish a minor change draft specialist document via UI          | No                                   | Not as a new entry (old entry updated)                       |
| Publish a minor change specialist documents via silent rake task | No                                   | Not as a new entry (old entry updated)                       |

## 2. When user is subscribed to the finder but not its organisation

A user can only subscribe to a live finder, so first finder publish is not considered here.

| Action                                                           | Sends email with finder prefix | Shows in the "Latest from" on the organisation page          |
|------------------------------------------------------------------|--------------------------------|--------------------------------------------------------------|
| Publish subsequent updates to the finder via developer rake task | No                             | Not as a new entry (old entry updated)                       |
| Publish a first draft specialist document via UI                 | Yes                            | Yes, new entry                                               |
| Publish first draft specialist documents via silent rake task    | No                             | Yes, new entry                                               |
| Publish a major change draft specialist document via UI          | Yes                            | Not as a new entry (old entry updated and bumped to the top) |
| Publish a major change specialist documents via silent rake task | No                             | Not as a new entry (old entry updated and bumped to the top) |
| Publish a minor change draft specialist document via UI          | No                             | Not as a new entry (old entry updated)                       |
| Publish a minor change specialist documents via silent rake task | No                             | Not as a new entry (old entry updated)                       |

## 3. When user is subscribed to both the finder and the organisation

A user can only subscribe to a live finder, so first finder publish is not considered here. They can subscribe to the organisation, the finder, or both, in any order. It seems a single email is sent, with the prefix of the most recent subscription. This was observed consistently, though not verified against code.

### 3.1. User subscribes to the organisation first and to the finder after

Note that it doesn't send organisation prefix emails.

| Action                                                           | Sends email with finder prefix | Sends email with organisation prefix | Shows in the "Latest from" on the organisation page          |
|------------------------------------------------------------------|--------------------------------|--------------------------------------|--------------------------------------------------------------|
| Publish subsequent updates to the finder via developer rake task | No                             | No                                   | Not as a new entry (old entry updated)                       |
| Publish a first draft specialist document via UI                 | Yes                            | No                                   | Yes, new entry                                               |
| Publish a first draft specialist documents via silent rake task  | No                             | No                                   | Yes, new entry                                               |
| Publish a major change draft specialist document via UI          | Yes                            | No                                   | Not as a new entry (old entry updated and bumped to the top) |
| Publish a major change specialist documents via silent rake task | No                             | No                                   | Not as a new entry (old entry updated and bumped to the top) |
| Publish a minor change draft specialist document via UI          | No                             | No                                   | Not as a new entry (old entry updated)                       |
| Publish a minor change specialist documents via silent rake task | No                             | No                                   | Not as a new entry (old entry updated)                       |


### 3.2. User subscribes to the finder first and to the organisation after

Note that it doesn't send finder prefix emails.

| Action                                                           | Sends email with finder prefix | Sends email with organisation prefix | Shows in the "Latest from" on the organisation page          |
|------------------------------------------------------------------|--------------------------------|--------------------------------------|--------------------------------------------------------------|
| Publish subsequent updates to the finder via developer rake task | No                             | No                                   | Not as a new entry (old entry updated)                       |
| Publish a first draft specialist document via UI                 | No                             | Yes                                  | Yes                                                          |
| Publish first draft specialist documents via silent rake task    | No                             | No                                   | Yes                                                          |
| Publish a major change draft specialist document via UI          | No                             | Yes                                  | Not as a new entry (old entry updated and bumped to the top) |
| Publish a major change specialist documents via silent rake task | No                             | No                                   | Not as a new entry (old entry updated and bumped to the top) |
| Publish a minor change draft specialist document via UI          | No                             | No                                   | Not as a new entry (old entry updated)                       |
| Publish a minor change specialist documents via silent rake task | No                             | No                                   | Not as a new entry (old entry updated)                       |


## Conclusions

- Specialist documents behave the same as any other document from another app, for organisation subscribers, with major changes sending email alerts and minor changes not sending email alerts.
- Email alerts are not being sent for the finder page itself.
- Specialist finders also offer their own subscription model, sending alerts for documents. 
- Subscribers to both the finder and organisations do not seem to get duplicated emails, but an email prefixed with whichever their last subscription was (either organisation or finder).
- The silent rake task ensures no emails are sent to subscribers to either the organisation or the finder, even when the change is major.
- The "Latest from" section on the organisation page shows all updates to documents and finder, regardless of the subscription status of the user or the use of the silent rake task. New items will be listed as new entries, while updates to existing entries will happen in place, with major updates also causing the entry to be bumped to the top of the list.