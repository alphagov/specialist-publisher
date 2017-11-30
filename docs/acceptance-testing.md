## Acceptance Testing

There is an RFC
[here](https://gov-uk.atlassian.net/wiki/display/GOVUK/RFC+50%3A+do+end-to-end+testing+of+GOV.UK+applications)
that proposes to introduce acceptance testing for GOV.UK applications. This
documentation is the result of
[this](https://trello.com/c/NVTeK1qP/165-figure-out-how-to-do-end-to-end-testing-of-specialist-publisher-rebuild-medium)
investigation which asks how we might technically achieve this. It goes into
moderate detail about some of the difficulties of setting up an acceptance
testing framework for GOV.UK applications and suggests how we might overcome
these.

**Disclaimer:** This writeup isn't as complete as I'd like it to be due to
leaving GDS before finishing the ticket I was working on. Someone may wish to
pick this work up and elaborate it further.

## What we have now

Currently, GOV.UK is split up across many applications that serve different
roles. There are many applications that work together to provide all of the
features pertaining to Specialist Documents, for example:

- Specialist Publisher
- Specialist Frontend
- Finders Frontend
- Publishing API
- Content Store
- Email Alert API

This list is not exhaustive.

We test each of the applications individually and in some cases do contract
testing across boundaries. For example, the Publishing API has some contract
tests with Content Store.

## What we want to achieve

We want to be able to test full end-to-end journeys through the application(s)
involved. We want to write tests like:

- Log in
- Create a draft
- Publish it
- Assert that the document appears on GOV.UK
- Assert that the document is searchable
- Assert that an email was received

Currently, it's not possible to do this. We test things that are indicative of
this behaviour, such as "has a request been sent to the email alert api" but we
don't check that an email has *actually* been received.

In addition to this, we want to encourage development practises such as
test- and behaviour-driven development where possible. This would allow
developers to start feature development by writing a set of high-level
user-acceptance tests and then use these to drive the development of the
feature.

For more information of these things, please refer to the RFC.

## Some analysis

If we want to encourage TDD/BDD workflows, we need to be able to run these
acceptance tests on the dev vm. This is so that developers can repeatedly run
them during feature development and receive feedback from them. Currently, the
recommended tool for running groups of GOV.UK applications is bowl.

When bowl is run, it starts the specified applications in 'development' mode. If
the developer has replicated data, this environment contains real data from
production. This data includes real user accounts that could be used to simulate
a user interacting with the various applications.

## Technical proposal

I propose we write a test-suite, or several test-suites that test vertical
slices through the system. For example, we'd have a test-suite for Specialist
Publisher that interacts with the publishing app and asserts that changes have
been effected on the frontend.

This test-suite would depend on bowl to start all of the required applications
and could either start the applications with bowl itself or check that they are
running before starting. This test-suite could be placed within the existing
Specialist Publisher app and would use a separate test context so that it does
not have access to the underlying implementation of the application.

The test-suite would interact with the application via Capybara and things like
WebMock would be disabled so that requests made to the application issue real
requests to its dependent services. Assertions could be made against any of the
dependent services, for example, a test could publish a document then asserts
those changes are visible on the frontend.

Depending on how the tests are run, it may be necessary to create a user in
Signon in order to grant the test-user access to the app(s). This is something
that will need to be figured out.

When writing acceptance tests, I'd recommend generating unique test data for
each run rather than relying on data already being in the system so that there
are fewer dependencies on the developer running the tests.

Finally, I'd recommend trying to containerise this test-suite so that it can
run on Jenkins. This may be difficult because, as far as I am aware, we haven't
run the full dev vm as part of a Jenkins build before. If the test-suite is
data agnostic, it may be possible to run this suite against an existing
integration/staging environment. We have also discussed the possibility of
having special "acceptance test" pages on the production environment. This could
be an opportunity to promote transparency (open is better) and explain how we
test GOV.UK applications.
