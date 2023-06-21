FROM jekyll/jekyll:latest
LABEL version=v0.0.1

RUN apk update
RUN apk upgrade
RUN apk add -U curl jq

ADD . /maps

ENV BUNDLE_GEMFILE=/maps/Gemfile
ENV VENDOR_BUNDLE=/vendor/bundle

RUN bundle install
ENTRYPOINT ["/maps/entrypoint.sh"]
