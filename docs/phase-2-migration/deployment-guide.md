## Deployment guide

After following this process, a specified finder would be served from v2 `specialist-publisher` as opposed to v1.

These steps will need to be taken for each environment. The steps below demonstrate the process for the `Integration` environment using the `raib` finder.

##### Republish V1 documents
This will enqueue the documents via Sidekiq.

* ssh into backend integration: `ssh backend-1.integration`

* Once inside backend integration go to: `cd /var/apps/specialist-publisher`

* Within `govuk_app_console specialist-publisher` check size of the Sidekiq queue using: `Sidekiq::Queue.all.first.size`

* Republish! `sudo su deploy govuk_setenv specialist-publisher bundle exec ruby ./bin/republish_documents raib_report`

(Please note - include `bundle exec` to ensure correct versions of dependencies are executed)

* Check the queue size a few times using `Sidekiq::Queue.all.first.size`. The number should have risen since originally running the republish script but should reduce subsequently

* Check the RetrySet. This re-runs jobs that have failed: `Sidekiq::RetrySet.new.size` - the number of jobs that fail should = 0

* Check that there are no errors in errbit

* Check that republished documents display a recent `updated_at` within the publishing-api

##### QA

* Work through the QA process which can be found [here](https://docs.google.com/spreadsheets/d/13LmDUgd2CKNjihtDP9KNHTtGtQaZls4O0p10eCFTrsg/edit#gid=1849433504)

##### Deploy the rebuild app

* Go to the release app within the browser: release.publishing.service.gov.uk
* Select most recent release tag. Scroll down and you will see the 'Deploy to staging' and 'Deploy to Production' buttons. Use these to deploy.

##### Puppet configuration

* If all QA has passed, on your local VM `cd` into `govuk-puppet`. Add the raib url (`/raib-reports`) into: `modules/govuk/manifests/node/s_backend_lb.pp`

```
modified_paths => {
  '/raib-reports' => {
    'app' => 'specialist-publisher-rebuild',
},
```

** Once puppet is deployed, the above step will make changes for all environments including production **

* Push this branch to Github, merge and deploy puppet

##### Load Balancers

* Run `govuk_puppet --test` on the load balancers:

Within `ssh backend-lb-1.backend.integration` run `govuk_puppet --test`

and

Within `ssh backend-lb-2.backend.integration` run `govuk_puppet --test`

* Console output should display that there has been a location change for `/raib-reports`
