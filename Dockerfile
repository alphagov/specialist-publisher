FROM ruby:2.5.1
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential nodejs && apt-get clean
# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb
RUN gem install foreman


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

RUN GOVUK_APP_DOMAIN=www.gov.uk RAILS_ENV=production bundle exec rails assets:precompile

HEALTHCHECK CMD curl --silent --fail localhost:$PORT || exit 1

CMD foreman run web
