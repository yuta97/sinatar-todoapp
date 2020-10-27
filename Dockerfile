FROM ruby:2.6.5

WORKDIR /app

ADD . /app

RUN bundle install
