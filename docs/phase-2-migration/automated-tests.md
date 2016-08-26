## Automated tests

We wrote a lot of automated tests while migrating Specialist Publisher to the
new platform. The general approach for these is:

1. Log in as an authenticated user
2. Stub API calls
3. Interact with the app
4. Assert that the right API calls are made
5. Assert that the right elements appear on the page

We found that we struggled to test user journeys. Normally, in a Rails app,
you'd mutate data in the database as you interact with the application. In our
case, all of the data for the app is persisted externally. By stubbing the data
persistance layer, we found we struggled to test user-journeys through the app.

To this day, this is something we haven't figured out completely. Instead, we
took a (lean?) approach and decided to plug this hole with a QA process instead
that would essentially test these user journeys before rolling out new formats
to production. In retrospect, this has become a time-consuming, onerous process
and we'd have probably taken a different approach from the beginning given the
luxury of some time to work on a better solution.

There is an RFC about this
[here](https://gov-uk.atlassian.net/wiki/display/GOVUK/RFC+50%3A+do+end-to-end+testing+of+GOV.UK+applications).

## Gotchas

[Here](https://github.com/alphagov/specialist-publisher-rebuild/blob/e613a6f48c0d006b3cb59e5622e9053134aa7c79/spec/features/publishing_a_cma_case_spec.rb#L54)
is a specific example of where we struggled with stubs.

In this example, we are testing the behaviour on publish. We are having to
resort to stubbing a sequence of responses from the Publishing API so that the
stubs are representative of what happens when you actually publish something,
i.e. its state changes to 'published' and it gets a 'first_published_at'
timestamp. One reason we need to do this is so that we can make an assertion
that Rummager receives the correct timestamp later on in this test.

This is far from intuitive and it is difficult to understand what the test is
doing. We had to add the `publishing_api_has_item_in_sequence` helper to
specifically address the need to stub a sequence of responses rather than a
single canned response.
