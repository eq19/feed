FROM jekyll/jekyll:latest
LABEL version=v0.0.1

RUN apk update
RUN apk upgrade --no-cache
RUN apk add -U curl jq yq

ADD . /maps

ENV BUNDLE_GEMFILE=/maps/Gemfile
ENV VENDOR_BUNDLE=/vendor/bundle

RUN bundle install
RUN chmod +x /maps/entrypoint.sh
ENTRYPOINT ["/maps/entrypoint.sh"]
