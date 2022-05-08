FROM ruby:2

WORKDIR /app
COPY Gemfile /app/
RUN bundle install

COPY . /app
