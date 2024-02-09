FROM ruby:3.3.0-alpine3.19 as base
ENV RUBY_YJIT_ENABLE=1
WORKDIR /acerola
RUN apk update && apk add build-base bash bash-completion postgresql-dev

FROM base
COPY Gemfile* .
RUN bundle install
COPY . .
EXPOSE 9292

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0"]
