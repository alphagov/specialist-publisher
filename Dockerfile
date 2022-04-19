FROM ruby:2.7.6

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential nodejs && apt-get clean

RUN gem install foreman

# This is not a valid key but it needs to be in the correct format for the ruby client
ENV GOVUK_NOTIFY_API_KEY test-b56ea330-006a-459b-8af3-8015bb51a0e7-77b95465-3c02-4b09-9371-44e33cbdf9c6

ENV GOVUK_APP_NAME specialist-publisher
ENV MONGODB_URI mongodb://mongo/govuk-content
ENV PORT 3064
ENV RAILS_ENV development
ENV REDIS_HOST redis
ENV TEST_MONGODB_URI mongodb://mongo/specialist-publisher-test

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

RUN GOVUK_APP_DOMAIN=www.gov.uk GOVUK_WEBSITE_ROOT=www.gov.uk RAILS_ENV=production bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD foreman run web
