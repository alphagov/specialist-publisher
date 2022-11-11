ARG base_image=ghcr.io/alphagov/govuk-ruby-base:3.1.2
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:3.1.2

FROM $builder_image AS builder

WORKDIR /app

COPY Gemfile* .ruby-version /app/

RUN bundle install

COPY . /app

# This is not a valid key but it needs to be in the correct format for the ruby client
ENV GOVUK_NOTIFY_API_KEY=test-b56ea330-006a-459b-8af3-8015bb51a0e7-77b95465-3c02-4b09-9371-44e33cbdf9c6

RUN bundle exec rails assets:precompile && rm -fr /app/log


FROM $base_image

ENV GOVUK_APP_NAME=specialist-publisher

WORKDIR /app

COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app /app/

USER app

CMD ["bundle", "exec", "puma"]
