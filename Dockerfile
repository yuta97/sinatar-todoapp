FROM ruby:2.6.5

WORKDIR /app

ADD . /app

RUN apt-get update && apt-get install -y \
build-essential \
libmariadb-dev \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* \
&& bundle install
