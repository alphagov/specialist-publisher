## Setting the scene

A decision was made in 2015 to rewrite the Specialist Publisher app. The
previous implementation stored its data in Mongo and used
[GOV.UK Content Models](https://github.com/alphagov/govuk_content_models).
It was decided that the rewrite would use the new Publishing Platform in its
full capacity. This means that it would not only publish its content through the
Publishing API, but it would store all of its data there, too. At the time the
Publishing API was under heavy development and the rewrite was used to drive out
features and specify requirements.

There's a blog post about this here:
[The Specialist Publisher rebuild: behind the scenes](https://insidegovuk.blog.gov.uk/2016/07/29/the-specialist-publisher-rebuild-behind-the-scenes/)
