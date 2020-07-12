FROM ruby:alpine3.12

RUN mkdir /clidapp
COPY transliterator.rb app.rb Gemfile Gemfile.lock config.ru /clidapp/
WORKDIR /clidapp/

RUN apk add --update build-base linux-headers && gem install bundler && \
  bundle install && apk del \
  build-base \
  g++ \
  gcc \
  binutils \
  libatomic \
  libgomp \
  libstdc++ \
  make \
  libc-dev \
  musl-dev \
  fortify-headers \
  linux-headers \
  mpc1 \
  mpfr4 \
  isl \
  gmp \
  libgcc \
  && rm -rf /var/cache/apk/*
CMD unicorn

EXPOSE 8080
